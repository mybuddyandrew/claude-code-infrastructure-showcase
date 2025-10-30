---
name: rails-backend-guidelines
description: Comprehensive backend development guide for Ruby on Rails applications. Use when creating controllers, models, services, routes, migrations, or working with ActiveRecord, Devise, Pundit, concerns, background jobs, or Rails APIs. Covers Rails MVC architecture, service objects pattern, authentication/authorization, database best practices, and testing strategies with Minitest.
---

# Rails Backend Development Guidelines

## Purpose

Establish consistency and best practices across Rails applications (APIs, full-stack, engines) using modern Ruby on Rails patterns - supporting both personal projects and team development.

## When to Use This Skill

Automatically activates when working on:
- Creating or modifying controllers, routes, APIs
- Building models with ActiveRecord
- Implementing service objects for business logic
- Using concerns for shared behavior
- Database operations (migrations, queries, associations)
- Authentication with Devise
- Authorization with Pundit
- Background jobs (Sidekiq, Delayed Job)
- Rails testing with Minitest
- API serialization and versioning

---

## Quick Start

### New Rails Feature Checklist

- [ ] **Route**: RESTful definition in `config/routes.rb`
- [ ] **Controller**: Inherit from `ApplicationController`
- [ ] **Service Object**: Extract complex business logic
- [ ] **Model**: ActiveRecord with validations and associations
- [ ] **Authorization**: Pundit policy (if needed)
- [ ] **Tests**: Minitest coverage (model, controller, integration)
- [ ] **Serializer**: JSON response structure (for APIs)
- [ ] **Background Job**: For async operations (if needed)

### New Rails Application Checklist

- [ ] Directory structure follows Rails conventions
- [ ] Devise configured for authentication
- [ ] Pundit setup for authorization
- [ ] Service objects directory (`app/services/`)
- [ ] Background job processor (Sidekiq/Delayed Job)
- [ ] API versioning structure (for APIs)
- [ ] Test framework configured (Minitest)
- [ ] Database connection pooling
- [ ] CORS configuration (for APIs)

---

## Architecture Overview

### Rails MVC + Service Objects Pattern

```
HTTP Request
    ↓
Routes (config/routes.rb)
    ↓
Controllers (request handling)
    ↓
Service Objects (business logic)
    ↓
Models (data validation & persistence)
    ↓
Database (ActiveRecord → SQL)
```

**Key Principle:** Thin controllers, fat service objects, smart models.

**See [architecture-overview.md](resources/architecture-overview.md) for complete details.**

---

## Directory Structure

```
app/
├── controllers/         # Request handlers
│   ├── api/            # API controllers (namespaced)
│   ├── concerns/       # Shared controller behavior
│   └── application_controller.rb
├── models/             # ActiveRecord models
│   ├── concerns/       # Shared model behavior
│   └── application_record.rb
├── services/           # Business logic (custom directory)
│   ├── posts/          # Organized by domain
│   ├── users/
│   └── base_service.rb
├── policies/           # Pundit authorization
│   └── application_policy.rb
├── jobs/               # Background jobs
│   └── application_job.rb
├── mailers/            # Email handling
├── serializers/        # JSON serialization (if using AMS)
└── views/              # View templates (full-stack apps)

config/
├── routes.rb           # Route definitions
├── database.yml        # Database configuration
├── initializers/       # Configuration files
│   ├── devise.rb
│   └── pundit.rb
└── environments/       # Environment-specific config

db/
├── migrate/            # Database migrations
├── schema.rb           # Database schema (auto-generated)
└── seeds.rb            # Seed data

test/
├── controllers/        # Controller tests
├── models/             # Model tests
├── integration/        # Integration tests
├── fixtures/           # Test data
└── test_helper.rb
```

**Naming Conventions:**
- Controllers: `PascalCase` - `PostsController`, `Api::V1::UsersController`
- Models: `PascalCase`, singular - `Post`, `User`
- Services: `PascalCase` - `PostCreationService`, `UserRegistrationService`
- Concerns: `PascalCase` - `Authenticable`, `Searchable`
- Jobs: `PascalCase` - `WelcomeEmailJob`, `DataExportJob`
- Policies: `PascalCase + Policy` - `PostPolicy`, `UserPolicy`

---

## Core Patterns

### 1. Controllers - Request Handling

**Purpose:** Handle HTTP requests, delegate to services, return responses

```ruby
class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :update, :destroy]

  def index
    @posts = Post.published.order(created_at: :desc)
    authorize @posts
    render json: @posts
  end

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

  private

  def set_post
    @post = Post.find(params[:id])
    authorize @post
  end

  def post_params
    params.require(:post).permit(:title, :body, :published)
  end
end
```

**See [controllers.md](resources/controllers.md) for complete controller patterns.**

---

### 2. Models - Data & Validation

**Purpose:** Data persistence, validations, associations, scopes

```ruby
class Post < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :tags, through: :post_tags

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :body, presence: true
  validates :user, presence: true

  # Scopes
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_author, ->(user_id) { where(user_id: user_id) }

  # Callbacks
  before_save :sanitize_body
  after_create :notify_followers

  # Class methods
  def self.search(query)
    where("title ILIKE ? OR body ILIKE ?", "%#{query}%", "%#{query}%")
  end

  # Instance methods
  def published?
    published && published_at.present?
  end

  private

  def sanitize_body
    self.body = ActionController::Base.helpers.sanitize(body)
  end

  def notify_followers
    NotifyFollowersJob.perform_later(self)
  end
end
```

**See [models.md](resources/models.md) for complete model patterns.**

---

### 3. Service Objects - Business Logic

**Purpose:** Extract complex business logic from controllers/models

```ruby
# app/services/base_service.rb
class BaseService
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  def success(data = {})
    ServiceResult.new(success: true, data: data)
  end

  def failure(errors)
    ServiceResult.new(success: false, errors: errors)
  end
end

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
        track_creation(post)
        success(post: post)
      else
        failure(post.errors)
      end
    end

    private

    def track_creation(post)
      Analytics.track(
        event: 'post_created',
        user_id: @current_user.id,
        post_id: post.id
      )
    end
  end
end

# app/services/service_result.rb
class ServiceResult
  attr_reader :data, :errors

  def initialize(success:, data: {}, errors: [])
    @success = success
    @data = data
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
```

**See [services.md](resources/services.md) for complete service object patterns.**

---

### 4. Concerns - Shared Behavior

**Purpose:** Extract reusable modules for controllers and models

```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, ->(query) {
      where("#{table_name}.#{searchable_fields.join(" ILIKE :query OR #{table_name}.")} ILIKE :query",
            query: "%#{query}%")
    }
  end

  class_methods do
    def searchable_fields
      column_names.select { |col| column_for_attribute(col).type == :string }
    end
  end
end

# Usage in model
class Post < ApplicationRecord
  include Searchable
end
```

**See [concerns.md](resources/concerns.md) for complete concern patterns.**

---

### 5. Routes - RESTful Routing

**Purpose:** Define HTTP endpoints following REST conventions

```ruby
# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  # Standard RESTful routes
  resources :posts do
    member do
      post :publish
      post :unpublish
    end

    resources :comments, only: [:index, :create, :destroy]
  end

  # API versioning
  namespace :api do
    namespace :v1 do
      resources :posts, only: [:index, :show, :create, :update, :destroy]
      resources :users, only: [:show, :update] do
        get :posts, on: :member
      end
    end
  end

  # Health check
  get '/health', to: 'health#index'

  root 'posts#index'
end
```

**See [routes.md](resources/routes.md) for complete routing patterns.**

---

### 6. Migrations - Database Changes

**Purpose:** Version-controlled database schema changes

```ruby
class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.boolean :published, default: false, null: false
      t.datetime :published_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :posts, :published
    add_index :posts, :published_at
    add_index :posts, [:user_id, :created_at]
  end
end
```

**See [migrations.md](resources/migrations.md) for safe migration patterns.**

---

## Authentication & Authorization

### Devise - Authentication

```ruby
# User model
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
end

# Controller
class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
```

**See [authentication.md](resources/authentication.md) for Devise patterns.**

---

### Pundit - Authorization

```ruby
# Policy
class PostPolicy < ApplicationPolicy
  def update?
    user.present? && (record.user == user || user.admin?)
  end

  def destroy?
    update?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.where(published: true)
      end
    end
  end
end

# Controller usage
class PostsController < ApplicationController
  def index
    @posts = policy_scope(Post)
  end

  def update
    @post = Post.find(params[:id])
    authorize @post
    # ... update logic
  end
end
```

**See [authorization.md](resources/authorization.md) for Pundit patterns.**

---

## Background Jobs

```ruby
# Job definition
class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.welcome_email(user).deliver_now
  end
end

# Enqueue job
WelcomeEmailJob.perform_later(user)

# Enqueue with delay
WelcomeEmailJob.set(wait: 1.hour).perform_later(user)
```

**See [background-jobs.md](resources/background-jobs.md) for job patterns.**

---

## Testing with Minitest

```ruby
# Model test
class PostTest < ActiveSupport::TestCase
  test "should not save post without title" do
    post = Post.new(body: "Test body")
    assert_not post.save, "Saved the post without a title"
  end

  test "published scope returns only published posts" do
    published_post = posts(:published_one)
    unpublished_post = posts(:unpublished_one)

    assert_includes Post.published, published_post
    assert_not_includes Post.published, unpublished_post
  end
end

# Controller test
class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @post = posts(:one)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should create post" do
    assert_difference('Post.count') do
      post posts_url, params: { post: { title: "Test", body: "Body" } }
    end

    assert_redirected_to post_url(Post.last)
  end
end
```

**See [testing.md](resources/testing.md) for complete testing patterns.**

---

## Performance & Optimization

### N+1 Query Prevention

```ruby
# Bad - N+1 queries
@posts = Post.all
@posts.each do |post|
  puts post.user.name  # Triggers query for each post
end

# Good - Eager loading
@posts = Post.includes(:user)
@posts.each do |post|
  puts post.user.name  # Uses preloaded data
end

# Multiple associations
@posts = Post.includes(:user, :comments, :tags)

# Nested associations
@posts = Post.includes(comments: :user)
```

### Database Indexing

```ruby
# Add indexes for frequently queried columns
add_index :posts, :user_id
add_index :posts, :published
add_index :posts, [:user_id, :created_at]
add_index :posts, :title  # For exact matches
```

**See [performance.md](resources/performance.md) for optimization patterns.**

---

## Resource Files

Deep dive into specific topics:

1. **[architecture-overview.md](resources/architecture-overview.md)** - Rails architecture patterns
2. **[controllers.md](resources/controllers.md)** - Controller patterns and best practices
3. **[models.md](resources/models.md)** - ActiveRecord patterns, associations, validations
4. **[services.md](resources/services.md)** - Service object patterns
5. **[concerns.md](resources/concerns.md)** - Shared behavior with concerns
6. **[routes.md](resources/routes.md)** - RESTful routing patterns
7. **[migrations.md](resources/migrations.md)** - Safe database migrations
8. **[authentication.md](resources/authentication.md)** - Devise authentication patterns
9. **[authorization.md](resources/authorization.md)** - Pundit authorization patterns
10. **[background-jobs.md](resources/background-jobs.md)** - Background job patterns
11. **[testing.md](resources/testing.md)** - Minitest testing strategies
12. **[performance.md](resources/performance.md)** - Performance optimization

---

## Quick Reference

### Common Commands

```bash
# Generate resources
rails generate controller Posts index show create
rails generate model Post title:string body:text user:references
rails generate migration AddPublishedToPosts published:boolean
rails generate job WelcomeEmail

# Database
rails db:create
rails db:migrate
rails db:rollback
rails db:seed
rails db:reset

# Testing
rails test
rails test:models
rails test:controllers
rails test test/models/post_test.rb

# Console
rails console
rails console --sandbox

# Routes
rails routes
rails routes | grep posts
```

### Rails Patterns Checklist

✅ **Controllers** - Thin, delegate to services
✅ **Models** - Validations, associations, scopes
✅ **Services** - Extract complex business logic
✅ **Concerns** - DRY up shared behavior
✅ **Routes** - RESTful conventions
✅ **Migrations** - Reversible, safe
✅ **Authentication** - Devise for users
✅ **Authorization** - Pundit for permissions
✅ **Background Jobs** - Async processing
✅ **Tests** - Comprehensive Minitest coverage
✅ **Performance** - Eager loading, indexes

---

## Anti-Patterns to Avoid

❌ **Fat controllers** - Business logic in controllers
❌ **God objects** - Models doing too much
❌ **Skipping validations** - `save(validate: false)`
❌ **N+1 queries** - Missing eager loading
❌ **Callback hell** - Too many model callbacks
❌ **Missing indexes** - Slow database queries
❌ **Exposing all attributes** - Security risk
❌ **Inconsistent naming** - Breaking conventions
❌ **Missing tests** - Untested critical paths
❌ **Synchronous jobs** - Blocking requests

---

## Getting Started

**New to this skill?** Start here:
1. Read [architecture-overview.md](resources/architecture-overview.md)
2. Review [controllers.md](resources/controllers.md) and [models.md](resources/models.md)
3. Check [services.md](resources/services.md) for business logic patterns
4. Explore other resources as needed

**Working on a specific feature?** Jump to the relevant resource file above.

---

## Version

Rails Guidelines v1.0 - Last updated: 2025
Compatible with: Rails 7.x, Ruby 3.x
