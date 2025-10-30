# Migrations - Database Changes

## Creating Migrations

```bash
rails generate migration CreatePosts title:string body:text
rails generate migration AddPublishedToPosts published:boolean
rails generate migration AddUserToPosts user:references
```

## Safe Migrations

```ruby
class AddPublishedToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :published, :boolean, default: false, null: false
    add_index :posts, :published
  end
end

# Reversible migrations
class UpdatePostStatus < ActiveRecord::Migration[7.0]
  def up
    add_column :posts, :status, :integer, default: 0
  end

  def down
    remove_column :posts, :status
  end
end
```

## Common Patterns

```ruby
# Add column
add_column :posts, :views_count, :integer, default: 0

# Add index
add_index :posts, :user_id
add_index :posts, [:user_id, :created_at]

# Add foreign key
add_foreign_key :posts, :users

# Change column
change_column :posts, :title, :string, null: false
change_column_default :posts, :published, from: nil, to: false

# Remove column
remove_column :posts, :old_field
```

## See Also
- [models.md](models.md) - Model patterns
