# Authorization - Pundit Patterns

## Purpose

Handle user permissions and authorization using Pundit - a minimal authorization library that uses plain Ruby classes.

## Installation

```bash
# Gemfile
gem 'pundit'

# Install
bundle install
rails generate pundit:install
```

---

## Basic Setup

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
```

---

## Basic Policy

```ruby
# app/policies/application_policy.rb
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "Must define #resolve in policy scope"
    end

    private

    attr_reader :user, :scope
  end
end

# app/policies/post_policy.rb
class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

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
      elsif user
        scope.where(published: true).or(scope.where(user: user))
      else
        scope.where(published: true)
      end
    end
  end
end
```

---

## Controller Usage

```ruby
class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @posts = policy_scope(Post)
  end

  def show
    @post = Post.find(params[:id])
    authorize @post
  end

  def create
    @post = Post.new(post_params)
    authorize @post

    if @post.save
      redirect_to @post
    else
      render :new
    end
  end

  def update
    @post = Post.find(params[:id])
    authorize @post

    if @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    authorize @post
    @post.destroy
    redirect_to posts_path
  end
end
```

---

## Advanced Policies

```ruby
class PostPolicy < ApplicationPolicy
  # Custom action
  def publish?
    user.present? && (record.user == user || user.admin?)
  end

  # Check multiple conditions
  def update?
    user.present? && can_update?
  end

  # Role-based
  def destroy?
    user&.admin? || (user&.moderator? && record.user == user)
  end

  # Permitted attributes
  def permitted_attributes
    if user.admin?
      [:title, :body, :published, :featured, :category_id]
    else
      [:title, :body, :published, :category_id]
    end
  end

  private

  def can_update?
    record.user == user || user.admin? || user.editor?
  end
end
```

---

## Testing

```ruby
require 'test_helper'

class PostPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @admin = users(:admin)
    @post = posts(:one)
  end

  test "user can update own post" do
    assert PostPolicy.new(@user, @user.posts.first).update?
  end

  test "user cannot update other user's post" do
    assert_not PostPolicy.new(@other_user, @post).update?
  end

  test "admin can update any post" do
    assert PostPolicy.new(@admin, @post).update?
  end
end
```

---

## See Also

- [authentication.md](authentication.md) - Devise patterns
- [controllers.md](controllers.md) - Controller patterns
