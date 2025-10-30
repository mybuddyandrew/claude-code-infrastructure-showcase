# Service Objects - Business Logic

## Purpose

Service objects encapsulate complex business logic that doesn't belong in controllers or models. They make code more testable, reusable, and maintainable.

## When to Use Service Objects

✅ **Complex business logic** - Multi-step operations
✅ **Multiple models** - Operations involving several models
✅ **External APIs** - Third-party service integration
✅ **Fat controllers/models** - Refactoring bloated classes
✅ **Reusable operations** - Logic used in multiple places

❌ **Simple CRUD** - Standard create/update/delete
❌ **One-line operations** - Keep in models
❌ **View logic** - Use helpers or presenters

---

## Base Service Pattern

```ruby
# app/services/base_service.rb
class BaseService
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  def call
    raise NotImplementedError, "Subclasses must implement #call"
  end

  protected

  def success(data = {})
    ServiceResult.new(success: true, data: data)
  end

  def failure(errors)
    ServiceResult.new(success: false, errors: normalize_errors(errors))
  end

  private

  def normalize_errors(errors)
    case errors
    when ActiveModel::Errors
      errors.full_messages
    when Array
      errors
    when String
      [errors]
    else
      [errors.to_s]
    end
  end
end

# app/services/service_result.rb
class ServiceResult
  attr_reader :data, :errors

  def initialize(success:, data: {}, errors: [])
    @success = success
    @data = OpenStruct.new(data)
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  # Allow accessing data directly
  def method_missing(method, *args)
    @data.respond_to?(method) ? @data.send(method, *args) : super
  end

  def respond_to_missing?(method, include_private = false)
    @data.respond_to?(method) || super
  end
end
```

---

## Simple Service Example

```ruby
# app/services/posts/creation_service.rb
module Posts
  class CreationService < BaseService
    def initialize(params:, current_user:)
      @params = params
      @current_user = current_user
    end

    def call
      post = @current_user.posts.build(@params)

      if post.save
        notify_followers(post)
        track_event(post)
        success(post: post)
      else
        failure(post.errors)
      end
    end

    private

    def notify_followers(post)
      NotifyFollowersJob.perform_later(post)
    end

    def track_event(post)
      Analytics.track(
        event: 'post_created',
        user_id: @current_user.id,
        post_id: post.id
      )
    end
  end
end

# Usage in controller
def create
  result = Posts::CreationService.call(
    params: post_params,
    current_user: current_user
  )

  if result.success?
    render json: result.post, status: :created
  else
    render json: { errors: result.errors }, status: :unprocessable_entity
  end
end
```

---

## Complex Service Example

```ruby
# app/services/posts/publication_service.rb
module Posts
  class PublicationService < BaseService
    def initialize(post:, current_user:)
      @post = post
      @current_user = current_user
    end

    def call
      return failure("Post already published") if @post.published?
      return failure("Post missing required fields") unless valid_for_publication?

      ActiveRecord::Base.transaction do
        publish_post
        notify_subscribers
        schedule_social_media_posts
        update_search_index
      end

      success(post: @post)
    rescue StandardError => e
      Rails.logger.error("Publication failed: #{e.message}")
      failure("Failed to publish post: #{e.message}")
    end

    private

    def valid_for_publication?
      @post.title.present? && @post.body.present? && @post.category.present?
    end

    def publish_post
      @post.update!(
        published: true,
        published_at: Time.current,
        published_by_id: @current_user.id
      )
    end

    def notify_subscribers
      @post.user.followers.find_each do |follower|
        PostPublishedMailer.notify(follower, @post).deliver_later
      end
    end

    def schedule_social_media_posts
      SocialMediaPostJob.set(wait: 5.minutes).perform_later(@post)
    end

    def update_search_index
      SearchIndexJob.perform_later(@post)
    end
  end
end
```

---

## Service with External API

```ruby
# app/services/external/image_upload_service.rb
module External
  class ImageUploadService < BaseService
    def initialize(file:, user:)
      @file = file
      @user = user
    end

    def call
      validate_file!

      response = upload_to_cdn
      return failure("Upload failed: #{response[:error]}") unless response[:success]

      create_image_record(response[:url])
      success(image: @image, url: response[:url])
    rescue StandardError => e
      Rails.logger.error("Image upload failed: #{e.message}")
      failure("Upload failed: #{e.message}")
    end

    private

    def validate_file!
      raise "File is required" if @file.blank?
      raise "File too large" if @file.size > 10.megabytes
      raise "Invalid file type" unless valid_content_type?
    end

    def valid_content_type?
      ['image/jpeg', 'image/png', 'image/gif'].include?(@file.content_type)
    end

    def upload_to_cdn
      # Integration with S3, Cloudinary, etc.
      cdn_client.upload(@file)
    end

    def create_image_record(url)
      @image = @user.images.create!(
        url: url,
        filename: @file.original_filename,
        content_type: @file.content_type,
        size: @file.size
      )
    end

    def cdn_client
      @cdn_client ||= CdnClient.new
    end
  end
end
```

---

## Service with Multiple Steps

```ruby
# app/services/users/registration_service.rb
module Users
  class RegistrationService < BaseService
    def initialize(params:)
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        create_user
        create_profile
        assign_default_role
        send_welcome_email
        track_registration
      end

      success(user: @user, profile: @profile)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors)
    rescue StandardError => e
      Rails.logger.error("Registration failed: #{e.message}")
      failure("Registration failed")
    end

    private

    def create_user
      @user = User.create!(
        email: @params[:email],
        password: @params[:password],
        password_confirmation: @params[:password_confirmation]
      )
    end

    def create_profile
      @profile = @user.create_profile!(
        name: @params[:name],
        bio: @params[:bio]
      )
    end

    def assign_default_role
      @user.add_role(:member)
    end

    def send_welcome_email
      UserMailer.welcome_email(@user).deliver_later
    end

    def track_registration
      Analytics.track(
        event: 'user_registered',
        user_id: @user.id,
        source: @params[:source]
      )
    end
  end
end
```

---

## Service with Validation

```ruby
# app/services/posts/bulk_update_service.rb
module Posts
  class BulkUpdateService < BaseService
    MAX_POSTS = 100

    def initialize(post_ids:, attributes:, current_user:)
      @post_ids = post_ids
      @attributes = attributes
      @current_user = current_user
    end

    def call
      validate_input!
      validate_permissions!

      updated_count = update_posts
      success(updated_count: updated_count)
    rescue ValidationError => e
      failure(e.message)
    rescue StandardError => e
      Rails.logger.error("Bulk update failed: #{e.message}")
      failure("Bulk update failed")
    end

    private

    def validate_input!
      raise ValidationError, "No posts selected" if @post_ids.blank?
      raise ValidationError, "Too many posts (max #{MAX_POSTS})" if @post_ids.size > MAX_POSTS
      raise ValidationError, "No attributes to update" if @attributes.blank?
    end

    def validate_permissions!
      posts = Post.where(id: @post_ids)
      unauthorized = posts.reject { |post| @current_user.can_update?(post) }

      if unauthorized.any?
        raise ValidationError, "Not authorized to update #{unauthorized.size} post(s)"
      end
    end

    def update_posts
      Post.where(id: @post_ids).update_all(@attributes.merge(updated_at: Time.current))
    end

    class ValidationError < StandardError; end
  end
end
```

---

## Organizing Services

### By Domain

```
app/services/
├── base_service.rb
├── service_result.rb
├── posts/
│   ├── creation_service.rb
│   ├── update_service.rb
│   ├── publication_service.rb
│   └── deletion_service.rb
├── users/
│   ├── registration_service.rb
│   ├── authentication_service.rb
│   └── profile_update_service.rb
└── external/
    ├── image_upload_service.rb
    ├── payment_processor_service.rb
    └── email_verification_service.rb
```

---

## Testing Services

```ruby
# test/services/posts/creation_service_test.rb
require 'test_helper'

module Posts
  class CreationServiceTest < ActiveSupport::TestCase
    setup do
      @user = users(:one)
      @params = { title: 'Test Post', body: 'Test body' }
    end

    test "creates post successfully" do
      result = CreationService.call(params: @params, current_user: @user)

      assert result.success?
      assert_instance_of Post, result.post
      assert_equal 'Test Post', result.post.title
      assert_equal @user, result.post.user
    end

    test "returns failure with invalid params" do
      result = CreationService.call(params: { title: '' }, current_user: @user)

      assert result.failure?
      assert_includes result.errors, "Title can't be blank"
    end

    test "notifies followers after creation" do
      assert_enqueued_with(job: NotifyFollowersJob) do
        CreationService.call(params: @params, current_user: @user)
      end
    end
  end
end
```

---

## Best Practices

✅ **Single responsibility** - One service, one purpose
✅ **Consistent interface** - Use BaseService pattern
✅ **Return ServiceResult** - Standardize responses
✅ **Use transactions** - For multi-step operations
✅ **Handle errors** - Rescue and log appropriately
✅ **Test thoroughly** - Unit test each service
✅ **Descriptive names** - `PostCreationService` not `PostService`
✅ **Organize by domain** - Group related services

❌ **Too simple** - Don't overuse for basic operations
❌ **Too complex** - Break large services into smaller ones
❌ **Silent failures** - Always return result
❌ **Side effects** - Make them explicit and documented
❌ **Unclear naming** - Be specific about what the service does

---

## Common Patterns

### Service Chain

```ruby
def call
  step1_result = Step1Service.call(data)
  return failure(step1_result.errors) if step1_result.failure?

  step2_result = Step2Service.call(step1_result.output)
  return failure(step2_result.errors) if step2_result.failure?

  success(final_output: step2_result.output)
end
```

### Service with Dry-Validation

```ruby
class PostCreationService < BaseService
  def initialize(params:, current_user:)
    @params = params
    @current_user = current_user
  end

  def call
    validation = PostSchema.call(@params)
    return failure(validation.errors) if validation.failure?

    create_post(validation.to_h)
  end

  private

  def create_post(validated_params)
    post = @current_user.posts.create!(validated_params)
    success(post: post)
  end
end
```

---

## See Also

- [controllers.md](controllers.md) - Controller patterns
- [models.md](models.md) - Model best practices
- [testing.md](testing.md) - Testing strategies
