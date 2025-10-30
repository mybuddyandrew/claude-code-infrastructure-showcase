---
name: rails-api-patterns
description: Rails API development patterns including serialization, versioning, and API-only controllers. Use when building Rails APIs or working with JSON responses.
---

# Rails API Patterns

## Purpose

Patterns for building RESTful APIs with Rails, including serialization, versioning, and API-only controllers.

## Quick Start

```ruby
# API controller
module Api
  module V1
    class PostsController < ApplicationController
      def index
        @posts = Post.all
        render json: @posts
      end

      def show
        @post = Post.find(params[:id])
        render json: @post
      end
    end
  end
end
```

## API Versioning

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :posts
  end
end
```

## Coming Soon

Full API patterns documentation including:
- API versioning strategies
- Serialization (ActiveModel::Serializers, JBuilder)
- Authentication (JWT, API tokens)
- Error handling
- CORS configuration
- Rate limiting

## See Also

- [rails-backend-guidelines](../rails-backend-guidelines/SKILL.md) - Main Rails patterns
