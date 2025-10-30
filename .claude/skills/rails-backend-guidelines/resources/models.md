# Models - Data & Validation

## Purpose

ActiveRecord models handle data persistence, validations, associations, and business rules. They should be **smart** but not **fat** - complex logic should move to service objects.

## Core Principles

✅ **Validations** - Always validate data
✅ **Associations** - Define relationships clearly
✅ **Scopes** - Reusable query methods
✅ **Single responsibility** - One concern per model
✅ **Database constraints** - Mirror validations in DB

❌ **Business logic** - Complex operations → services
❌ **Fat models** - Too many responsibilities
❌ **Missing validations** - Data integrity issues

---

## Standard Model Structure

```ruby
class Post < ApplicationRecord
  # Concerns (load first)
  include Searchable
  include Publishable

  # Associations
  belongs_to :user
  belongs_to :category, optional: true
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_one_attached :cover_image

  # Enums
  enum status: { draft: 0, published: 1, archived: 2 }

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :body, presence: true, length: { minimum: 10 }
  validates :user, presence: true
  validate :published_posts_must_have_category

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :with_associations, -> { includes(:user, :category, :tags) }

  # Callbacks
  before_validation :set_defaults
  after_create :notify_followers
  after_update :clear_cache, if: :saved_change_to_published?

  # Class methods
  def self.search(query)
    where("title ILIKE ? OR body ILIKE ?", "%#{query}%", "%#{query}%")
  end

  def self.trending(days = 7)
    where("created_at >= ?", days.days.ago)
      .order(views_count: :desc)
      .limit(10)
  end

  # Instance methods
  def published?
    published && published_at.present?
  end

  def excerpt(length = 200)
    body.truncate(length, separator: ' ')
  end

  private

  def set_defaults
    self.published_at ||= Time.current if published?
  end

  def published_posts_must_have_category
    if published? && category.blank?
      errors.add(:category, "must be set for published posts")
    end
  end

  def notify_followers
    NotifyFollowersJob.perform_later(self)
  end

  def clear_cache
    Rails.cache.delete("post_#{id}")
  end
end
```

---

## Associations

### Belongs To

```ruby
class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  belongs_to :parent, class_name: 'Comment', optional: true

  # With custom foreign key
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'

  # With counter cache
  belongs_to :post, counter_cache: true

  # With touch (updates parent's updated_at)
  belongs_to :post, touch: true
end
```

### Has Many

```ruby
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :nullify

  # With conditions
  has_many :published_posts, -> { where(published: true) }, class_name: 'Post'

  # With custom foreign key
  has_many :authored_posts, class_name: 'Post', foreign_key: 'author_id'

  # With order
  has_many :posts, -> { order(created_at: :desc) }
end
```

### Has Many Through

```ruby
class Post < ApplicationRecord
  has_many :post_tags
  has_many :tags, through: :post_tags

  has_many :comments
  has_many :commenters, through: :comments, source: :user
end

class PostTag < ApplicationRecord
  belongs_to :post
  belongs_to :tag
end
```

### Has One

```ruby
class User < ApplicationRecord
  has_one :profile, dependent: :destroy
  has_one :account, through: :profile
end
```

---

## Validations

### Presence

```ruby
validates :title, presence: true
validates :user, presence: true
validates :category, presence: true, if: :published?
```

### Length

```ruby
validates :title, length: { maximum: 200 }
validates :body, length: { minimum: 10, maximum: 10000 }
validates :slug, length: { is: 8 }
```

### Format

```ruby
validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
validates :slug, format: { with: /\A[a-z0-9-]+\z/ }
```

### Uniqueness

```ruby
validates :email, uniqueness: true
validates :slug, uniqueness: { scope: :user_id }
validates :title, uniqueness: { case_sensitive: false }
```

### Custom Validations

```ruby
class Post < ApplicationRecord
  validate :end_date_after_start_date
  validate :reasonable_publish_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def reasonable_publish_date
    if published_at && published_at > 1.year.from_now
      errors.add(:published_at, "is too far in the future")
    end
  end
end
```

---

## Scopes

```ruby
class Post < ApplicationRecord
  # Simple scopes
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { where("views_count > ?", 100) }

  # Scopes with arguments
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_category, ->(category) { where(category: category) }
  scope :created_after, ->(date) { where("created_at >= ?", date) }

  # Chaining scopes
  scope :trending, -> { published.recent.popular }

  # Scopes with joins
  scope :with_comments, -> { joins(:comments).distinct }
  scope :by_tag, ->(tag_name) {
    joins(:tags).where(tags: { name: tag_name })
  }
end

# Usage
Post.published.recent.limit(10)
Post.by_user(current_user.id).published
```

---

## Callbacks

```ruby
class Post < ApplicationRecord
  # Before callbacks
  before_validation :normalize_title
  before_save :set_published_at
  before_create :generate_slug
  before_destroy :check_if_deletable

  # After callbacks
  after_create :notify_admin
  after_update :clear_cache, if: :saved_change_to_title?
  after_commit :index_for_search, on: [:create, :update]

  # Around callbacks
  around_save :transaction_with_logging

  private

  def normalize_title
    self.title = title.strip.titleize if title.present?
  end

  def set_published_at
    self.published_at = Time.current if published? && published_at.blank?
  end

  def generate_slug
    self.slug = title.parameterize if slug.blank?
  end

  def transaction_with_logging
    Rails.logger.info "Saving post #{id}"
    yield
    Rails.logger.info "Post #{id} saved successfully"
  end
end
```

**⚠️ Callback Warning:** Avoid callback hell. Complex operations should use service objects instead.

---

## Enums

```ruby
class Post < ApplicationRecord
  enum status: { draft: 0, published: 1, archived: 2 }
  enum visibility: { public_access: 0, private_access: 1, restricted: 2 }, _prefix: true

  # Usage
  post.draft!           # Set status to draft
  post.published?       # Check if published
  Post.published        # Scope for published posts
  post.visibility_public_access!  # With prefix
end
```

---

## Querying

### Basic Queries

```ruby
# Find
Post.find(1)
Post.find([1, 2, 3])
Post.find_by(slug: 'my-post')
Post.find_by!(slug: 'my-post')  # Raises if not found

# Where
Post.where(published: true)
Post.where("views_count > ?", 100)
Post.where(created_at: 1.week.ago..Time.current)

# Order
Post.order(created_at: :desc)
Post.order('views_count DESC, created_at DESC')

# Limit & Offset
Post.limit(10)
Post.offset(20).limit(10)

# Select
Post.select(:id, :title, :created_at)

# Pluck (returns array)
Post.pluck(:title)
Post.pluck(:id, :title)  # Returns array of arrays
```

### Eager Loading (N+1 Prevention)

```ruby
# Includes (uses multiple queries)
Post.includes(:user, :comments)

# Joins (uses single query with JOIN)
Post.joins(:user).where(users: { active: true })

# Eager Load (always uses LEFT OUTER JOIN)
Post.eager_load(:user)

# Preload (always uses separate queries)
Post.preload(:comments)

# Nested includes
Post.includes(comments: :user)
Post.includes(:user, comments: [:user, :likes])
```

---

## Concerns

Extract shared model behavior:

```ruby
# app/models/concerns/publishable.rb
module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where(published: true) }
    scope :unpublished, -> { where(published: false) }

    validates :published_at, presence: true, if: :published?
  end

  def publish!
    update!(published: true, published_at: Time.current)
  end

  def unpublish!
    update!(published: false)
  end

  def published?
    published && published_at.present?
  end
end

# Usage in model
class Post < ApplicationRecord
  include Publishable
end
```

---

## Best Practices

✅ **Always validate** - Don't trust user input
✅ **Use scopes** - Reusable queries
✅ **Eager load** - Prevent N+1 queries
✅ **Database indexes** - On foreign keys and frequently queried columns
✅ **Use concerns** - DRY up shared behavior
✅ **Meaningful names** - Clear association names
✅ **Document complex logic** - Comments for tricky code
✅ **Test thoroughly** - Model tests for validations, associations, scopes

❌ **Skip validations** - `save(validate: false)` only in migrations
❌ **Fat models** - Extract to services
❌ **Callback hell** - Use service objects
❌ **Missing indexes** - Check query performance
❌ **Exposing sensitive data** - Use serializers

---

## See Also

- [controllers.md](controllers.md) - Controller patterns
- [services.md](services.md) - Service object patterns
- [concerns.md](concerns.md) - Shared behavior
- [performance.md](performance.md) - Query optimization
