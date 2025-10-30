# Authentication - Devise Patterns

## Purpose

Handle user authentication (login, signup, password reset) using Devise - the most popular Rails authentication solution.

## Installation

```bash
# Add to Gemfile
gem 'devise'

# Install
bundle install
rails generate devise:install
rails generate devise User
rails db:migrate
```

---

## Basic Configuration

```ruby
# config/initializers/devise.rb
Devise.setup do |config|
  config.mailer_sender = 'noreply@example.com'
  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.timeout_in = 30.minutes
  config.sign_out_via = :delete
end
```

---

## User Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  has_many :posts, dependent: :destroy

  validates :name, presence: true

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    approved? ? super : :not_approved
  end
end

# Migration
class DeviseCreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true
  end
end
```

---

## Controller Integration

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password, :current_password])
  end
end

# Skip authentication for specific actions
class PostsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @posts = Post.all
  end
end
```

---

## Custom Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'register'
  }

  # Or with controllers
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }
end
```

---

## Custom Controllers

### Sessions Controller

```ruby
# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?

    respond_with resource, location: after_sign_in_path_for(resource)
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || dashboard_path
  end
end
```

### Registrations Controller

```ruby
# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?

    if resource.persisted?
      UserMailer.welcome_email(resource).deliver_later
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def after_sign_up_path_for(resource)
    dashboard_path
  end
end
```

---

## API Authentication (JWT)

```ruby
# Gemfile
gem 'devise-jwt'

# config/initializers/devise.rb
config.jwt do |jwt|
  jwt.secret = Rails.application.credentials.devise_jwt_secret_key
  jwt.dispatch_requests = [
    ['POST', %r{^/login$}]
  ]
  jwt.revocation_requests = [
    ['DELETE', %r{^/logout$}]
  ]
  jwt.expiration_time = 1.day.to_i
end

# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
end

# API controller
module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        render json: { user: UserSerializer.new(resource) }, status: :ok
      end

      def respond_to_on_destroy
        head :no_content
      end
    end
  end
end
```

---

## Helper Methods

```ruby
# In controllers and views
user_signed_in?           # Check if user is logged in
current_user              # Access current user
authenticate_user!        # Require authentication
user_session              # Access session

# In controllers only
sign_in(user)            # Sign in user
sign_out(user)           # Sign out user

# URL helpers
new_user_session_path    # Login page
destroy_user_session_path # Logout
new_user_registration_path # Signup page
edit_user_registration_path # Edit profile
```

---

## Custom Validations

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable

  # Custom password validation
  validate :password_complexity

  private

  def password_complexity
    return if password.blank?

    unless password.match(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}\z/)
      errors.add :password, 'must include at least one lowercase letter, one uppercase letter, and one digit'
    end
  end
end
```

---

## Email Confirmation

```ruby
# Enable in model
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable
end

# Custom confirmation mailer
class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      sign_in(resource)
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end
end
```

---

## Account Locking

```ruby
# Enable in model
class User < ApplicationRecord
  devise :database_authenticatable, :lockable

  # Optional: unlock via time
  # config.unlock_in = 1.hour

  # Optional: unlock via email
  # config.unlock_strategy = :email
end
```

---

## Testing

```ruby
# test/test_helper.rb
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

# In tests
test "requires authentication" do
  get posts_path
  assert_redirected_to new_user_session_path
end

test "allows authenticated access" do
  sign_in users(:one)
  get posts_path
  assert_response :success
end
```

---

## Best Practices

✅ **Use strong passwords** - Enforce complexity
✅ **Enable confirmable** - Email verification
✅ **Use lockable** - Prevent brute force
✅ **Timeout sessions** - Auto logout inactive users
✅ **Track sign-ins** - Monitor activity
✅ **Custom error messages** - User-friendly feedback

---

## See Also

- [authorization.md](authorization.md) - Pundit patterns
- [controllers.md](controllers.md) - Controller patterns
