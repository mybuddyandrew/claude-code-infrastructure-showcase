# Performance - Optimization Patterns

## N+1 Query Prevention

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

## Database Indexing

```ruby
# Add indexes for frequently queried columns
add_index :posts, :user_id
add_index :posts, :published
add_index :posts, [:user_id, :created_at]
add_index :posts, :title  # For exact matches

# Composite indexes
add_index :posts, [:user_id, :published, :created_at]
```

## Caching

```ruby
# Fragment caching
<% cache post do %>
  <%= render post %>
<% end %>

# Low-level caching
Rails.cache.fetch("post_#{id}", expires_in: 12.hours) do
  expensive_operation
end

# Russian doll caching
<% cache ['v1', @post] do %>
  <%= @post.title %>
  <% cache ['v1', @post, 'comments'] do %>
    <%= render @post.comments %>
  <% end %>
<% end %>
```

## Database Queries

```ruby
# Use select to load only needed columns
Post.select(:id, :title, :created_at)

# Use pluck for simple data
Post.pluck(:id, :title)  # Returns array

# Use find_each for large datasets
Post.find_each(batch_size: 1000) do |post|
  # Process post
end

# Use counter cache
class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
end

# Use exists? instead of present?
Post.where(published: true).exists?  # Better than .present?
```

## See Also
- [models.md](models.md) - Model query patterns
