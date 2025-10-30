# Concerns - Shared Behavior

## Model Concerns

```ruby
# app/models/concerns/publishable.rb
module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where(published: true) }
    validates :published_at, presence: true, if: :published?
  end

  def publish!
    update!(published: true, published_at: Time.current)
  end

  def unpublish!
    update!(published: false)
  end
end

# Usage
class Post < ApplicationRecord
  include Publishable
end
```

## Controller Concerns

```ruby
# app/controllers/concerns/paginable.rb
module Paginable
  extend ActiveSupport::Concern

  def paginate(collection)
    collection.page(params[:page]).per(params[:per_page] || 25)
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end
end

# Usage
class PostsController < ApplicationController
  include Paginable

  def index
    @posts = paginate(Post.all)
  end
end
```

## See Also
- [models.md](models.md) - Model patterns
- [controllers.md](controllers.md) - Controller patterns
