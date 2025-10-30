# Controllers - Request Handling

## Purpose

Controllers in Rails handle HTTP requests, coordinate with models/services, and return responses. They should be **thin** - delegating business logic to service objects and models.

## Core Principles

✅ **Thin controllers** - Minimal logic, delegate to services
✅ **RESTful actions** - Follow REST conventions when possible
✅ **Strong parameters** - Always filter params
✅ **Single responsibility** - Each action does one thing
✅ **Consistent responses** - Standard JSON/HTML formats

❌ **Business logic in controllers** - Extract to services
❌ **Database queries in actions** - Use models/services
❌ **Missing authorization** - Always check permissions

---

## Standard RESTful Controller

```ruby
class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize_post, only: [:edit, :update, :destroy]

  # GET /posts
  def index
    @posts = Post.published.includes(:user).order(created_at: :desc)
    @posts = @posts.page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @posts }
    end
  end

  # GET /posts/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @post }
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    result = Posts::CreationService.call(
      params: post_params,
      current_user: current_user
    )

    if result.success?
      respond_to do |format|
        format.html { redirect_to result.post, notice: 'Post created successfully.' }
        format.json { render json: result.post, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: result.errors }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  def update
    result = Posts::UpdateService.call(
      post: @post,
      params: post_params
    )

    if result.success?
      respond_to do |format|
        format.html { redirect_to @post, notice: 'Post updated successfully.' }
        format.json { render json: @post }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: result.errors }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post deleted successfully.' }
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post
    authorize @post
  end

  def post_params
    params.require(:post).permit(:title, :body, :published, :category_id, tag_ids: [])
  end
end
```

---

## API-Only Controller

For Rails APIs, inherit from `ActionController::API`:

```ruby
module Api
  module V1
    class PostsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_post, only: [:show, :update, :destroy]

      # GET /api/v1/posts
      def index
        @posts = policy_scope(Post)
                   .includes(:user, :tags)
                   .order(created_at: :desc)
                   .page(params[:page])

        render json: @posts, each_serializer: PostSerializer
      end

      # GET /api/v1/posts/:id
      def show
        authorize @post
        render json: @post, serializer: PostDetailSerializer
      end

      # POST /api/v1/posts
      def create
        authorize Post

        result = Posts::CreationService.call(
          params: post_params,
          current_user: current_user
        )

        if result.success?
          render json: result.post, status: :created, serializer: PostSerializer
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/posts/:id
      def update
        authorize @post

        result = Posts::UpdateService.call(
          post: @post,
          params: post_params
        )

        if result.success?
          render json: @post, serializer: PostSerializer
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/posts/:id
      def destroy
        authorize @post
        @post.destroy!

        head :no_content
      end

      private

      def set_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:title, :body, :published, :category_id, tag_ids: [])
      end
    end
  end
end
```

---

## Base Application Controller

```ruby
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password])
  end

  private

  def user_not_authorized
    respond_to do |format|
      format.html do
        flash[:alert] = "You are not authorized to perform this action."
        redirect_back(fallback_location: root_path)
      end
      format.json { render json: { error: 'Unauthorized' }, status: :forbidden }
    end
  end

  def record_not_found
    respond_to do |format|
      format.html do
        flash[:alert] = "Record not found."
        redirect_to root_path
      end
      format.json { render json: { error: 'Not found' }, status: :not_found }
    end
  end
end
```

---

## Custom Actions (Non-RESTful)

When you need custom actions beyond REST:

```ruby
class PostsController < ApplicationController
  # Member actions (operate on a single resource)
  def publish
    @post = Post.find(params[:id])
    authorize @post, :update?

    if @post.update(published: true, published_at: Time.current)
      redirect_to @post, notice: 'Post published successfully.'
    else
      redirect_to @post, alert: 'Failed to publish post.'
    end
  end

  # Collection actions (operate on multiple resources)
  def bulk_publish
    @posts = Post.where(id: params[:post_ids])
    authorize @posts, :bulk_update?

    @posts.update_all(published: true, published_at: Time.current)
    redirect_to posts_path, notice: "#{@posts.count} posts published."
  end
end

# Routes
resources :posts do
  member do
    post :publish
    post :unpublish
  end

  collection do
    post :bulk_publish
  end
end
```

---

## Nested Resources

```ruby
class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: [:show, :update, :destroy]

  # GET /posts/:post_id/comments
  def index
    @comments = @post.comments.includes(:user).order(created_at: :desc)
    render json: @comments
  end

  # POST /posts/:post_id/comments
  def create
    result = Comments::CreationService.call(
      post: @post,
      params: comment_params,
      current_user: current_user
    )

    if result.success?
      render json: result.comment, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:post_id/comments/:id
  def destroy
    authorize @comment
    @comment.destroy!
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
```

---

## Response Formats

### Standard JSON Response

```ruby
class Api::V1::PostsController < Api::V1::BaseController
  def index
    @posts = Post.all

    render json: {
      data: @posts.map { |post| PostSerializer.new(post).as_json },
      meta: {
        total: @posts.count,
        page: params[:page] || 1
      }
    }
  end

  def show
    @post = Post.find(params[:id])

    render json: {
      data: PostSerializer.new(@post).as_json
    }
  end

  def create
    result = Posts::CreationService.call(params: post_params, current_user: current_user)

    if result.success?
      render json: {
        data: PostSerializer.new(result.post).as_json,
        message: 'Post created successfully'
      }, status: :created
    else
      render json: {
        errors: result.errors
      }, status: :unprocessable_entity
    end
  end
end
```

### Error Response Format

```ruby
# Consistent error responses
def render_error(message, status = :unprocessable_entity)
  render json: {
    error: {
      message: message,
      status: Rack::Utils.status_code(status)
    }
  }, status: status
end

# Usage
def create
  if @post.save
    render json: @post, status: :created
  else
    render_error(@post.errors.full_messages.join(', '))
  end
end
```

---

## Pagination

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.published
                 .includes(:user)
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(params[:per_page] || 25)

    render json: {
      data: @posts.map { |post| PostSerializer.new(post).as_json },
      meta: pagination_meta(@posts)
    }
  end

  private

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end
end
```

---

## Filtering & Searching

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
    @posts = apply_filters(@posts)
    @posts = @posts.page(params[:page])

    render json: @posts
  end

  private

  def apply_filters(scope)
    scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
    scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?
    scope = scope.where(published: params[:published]) if params[:published].present?
    scope = scope.search(params[:q]) if params[:q].present?
    scope = scope.order(order_clause) if params[:sort].present?
    scope
  end

  def order_clause
    direction = params[:direction] == 'desc' ? 'DESC' : 'ASC'
    "#{params[:sort]} #{direction}"
  end
end
```

---

## Strong Parameters

### Basic Usage

```ruby
def post_params
  params.require(:post).permit(:title, :body, :published)
end
```

### Nested Attributes

```ruby
def post_params
  params.require(:post).permit(
    :title,
    :body,
    :published,
    tag_ids: [],
    comments_attributes: [:id, :body, :_destroy]
  )
end
```

### Conditional Permissions

```ruby
def post_params
  if current_user.admin?
    params.require(:post).permit(:title, :body, :published, :featured, :user_id)
  else
    params.require(:post).permit(:title, :body, :published)
  end
end
```

---

## Controller Concerns

Extract shared controller logic into concerns:

```ruby
# app/controllers/concerns/paginable.rb
module Paginable
  extend ActiveSupport::Concern

  included do
    helper_method :pagination_meta
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end
end

# Usage
class PostsController < ApplicationController
  include Paginable

  def index
    @posts = Post.page(params[:page])
    render json: { data: @posts, meta: pagination_meta(@posts) }
  end
end
```

---

## Best Practices

✅ **Use before_action filters** - DRY up common operations
✅ **Delegate to services** - Keep controllers thin
✅ **Always authorize** - Use Pundit or similar
✅ **Strong parameters** - Never trust user input
✅ **Consistent responses** - Standard JSON format
✅ **Handle errors gracefully** - rescue_from for common errors
✅ **Use serializers** - Format JSON responses consistently
✅ **RESTful when possible** - Follow Rails conventions
✅ **Test thoroughly** - Controller tests for all actions

---

## Common Patterns

### Flash Messages

```ruby
def create
  if @post.save
    redirect_to @post, notice: 'Post created successfully.'
  else
    flash.now[:alert] = 'Failed to create post.'
    render :new, status: :unprocessable_entity
  end
end
```

### Redirects

```ruby
# Redirect to resource
redirect_to @post

# Redirect with notice
redirect_to @post, notice: 'Success!'

# Redirect back
redirect_back(fallback_location: root_path)

# Redirect to URL
redirect_to posts_path
```

### Rendering

```ruby
# Render template
render :new

# Render with status
render :new, status: :unprocessable_entity

# Render JSON
render json: @post

# Render nothing
head :no_content

# Render partial
render partial: 'post', locals: { post: @post }
```

---

## Anti-Patterns

❌ **Fat controllers** - Business logic belongs in services
❌ **Multiple database queries** - Use eager loading
❌ **Missing authorization** - Always check permissions
❌ **Skipping strong parameters** - Security risk
❌ **Inconsistent responses** - Use standard formats
❌ **Too many custom actions** - Consider nested resources
❌ **Complex conditionals** - Extract to service objects

---

## See Also

- [services.md](services.md) - Service object patterns
- [models.md](models.md) - Model best practices
- [routes.md](routes.md) - Routing patterns
- [authorization.md](authorization.md) - Pundit patterns
