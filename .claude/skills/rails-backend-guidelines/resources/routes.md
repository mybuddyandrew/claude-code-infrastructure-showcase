# Routes - RESTful Routing

## Basic RESTful Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :posts
  # Creates: index, show, new, create, edit, update, destroy

  resources :posts, only: [:index, :show]
  resources :posts, except: [:destroy]

  # Nested resources
  resources :posts do
    resources :comments
  end

  # Member routes (single resource)
  resources :posts do
    member do
      post :publish
      delete :unpublish
    end
  end

  # Collection routes (all resources)
  resources :posts do
    collection do
      get :search
      post :bulk_delete
    end
  end
end
```

## API Versioning

```ruby
namespace :api do
  namespace :v1 do
    resources :posts
    resources :users, only: [:show, :update]
  end
end
```

## See Also
- [controllers.md](controllers.md) - Controller patterns
