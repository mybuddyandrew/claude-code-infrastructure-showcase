# Testing - Minitest Patterns

## Model Tests

```ruby
# test/models/post_test.rb
require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test "should not save post without title" do
    post = Post.new(body: "Test")
    assert_not post.save
  end

  test "published scope returns only published posts" do
    published = posts(:published_one)
    unpublished = posts(:unpublished_one)

    assert_includes Post.published, published
    assert_not_includes Post.published, unpublished
  end
end
```

## Controller Tests

```ruby
# test/controllers/posts_controller_test.rb
require 'test_helper'

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

## Integration Tests

```ruby
# test/integration/user_creates_post_test.rb
require 'test_helper'

class UserCreatesPostTest < ActionDispatch::IntegrationTest
  test "user creates a new post" do
    sign_in users(:one)
    
    get new_post_path
    assert_response :success

    post posts_path, params: {
      post: { title: "New Post", body: "Post body" }
    }

    assert_redirected_to post_path(Post.last)
    follow_redirect!
    
    assert_select 'h1', 'New Post'
  end
end
```

## Fixtures

```yaml
# test/fixtures/posts.yml
one:
  title: First Post
  body: This is the first post
  published: true
  user: one

two:
  title: Second Post
  body: This is the second post
  published: false
  user: two
```

## See Also
- [models.md](models.md) - Model patterns
- [controllers.md](controllers.md) - Controller patterns
- [services.md](services.md) - Service testing
