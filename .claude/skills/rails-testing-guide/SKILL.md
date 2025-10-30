---
name: rails-testing-guide
description: Rails testing patterns with Minitest, fixtures, and integration tests. Use when writing tests for models, controllers, or creating integration tests.
---

# Rails Testing Guide

## Purpose

Comprehensive testing patterns for Rails applications using Minitest (default Rails testing framework).

## Quick Start

```ruby
# Model test
class PostTest < ActiveSupport::TestCase
  test "should not save without title" do
    post = Post.new(body: "Test")
    assert_not post.save
  end
end

# Controller test
class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get posts_url
    assert_response :success
  end
end
```

## Coming Soon

Full testing patterns documentation including:
- Model tests
- Controller tests
- Integration tests
- Fixtures
- Test helpers
- Assertions

## See Also

- [rails-backend-guidelines](../rails-backend-guidelines/SKILL.md) - Main Rails patterns
