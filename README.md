storage_unit
=========

[![Travis][0]](https://travis-ci.org/dobtco/storage_unit)
[![Code Climate][1]](https://codeclimate.com/github/dobtco/storage_unit)
[![Coveralls][2]](https://coveralls.io/r/dobtco/storage_unit)
[![RubyGem][3]](http://rubygems.org/gems/storage_unit)

:recycle: Soft deletion for Rails 4.1+, done right.

## Goals

- Standard set of "soft deletion" methods (`trash`, `recover`, `trashed?`)
- Explicit storage_unit dependencies (automatically trash associated records)
- Low-overhead (minimize queries)
- No validations on `recover`. (If your records became invalid after they were trashed, check for this yourself)
- Small, readable codebase

## Non-goals

- Targeting anything less than Rails 4.1
- Reflection on Rails' associations
- Generally, anything weird or complex happening behind the scenes

## Installation

```ruby
# In your Gemfile:
gem 'storage_unit'

# In a migration:
add_column :posts, :deleted_at, :datetime
```

## Usage

```ruby
class Post < ActiveRecord::Base
  has_storage_unit
end

post = Post.create
Post.all # => [post]
post.trashed? # => false

post.trash!
post.trashed? # => true
Post.all # => []
Post.with_deleted.all # => [post]

post.recover!
post.trashed? # => false
Post.all # => []
```

### Cascading trashes

```ruby
class User < ActiveRecord::Base
  has_storage_unit, cascade: [:posts]
  has_many :posts
end

class Post < ActiveRecord::Base
  has_storage_unit
end

user = User.create
post = Post.create

user.trash!
user.trashed? # => true
post.trashed? # => true

user.recover!
user.trashed? # => false
post.trashed? # => false
```

### Callbacks

```ruby
class Post < ActiveRecord::Base
  has_storage_unit
  after_recover :ensure_record_is_still_valid

  private
  def ensure_record_is_still_valid
    if !valid?
      # i dunno, trash! this post again? delete it entirely? inform the user? shit is hard.
    end
  end
end
```

### Use a different column

```ruby
class Post < ActiveRecord::Base
  has_storage_unit column: :trashed_at
end
```

## License
MIT.

[0]: https://img.shields.io/travis/dobtco/storage_unit.svg
[1]: https://img.shields.io/codeclimate/github/dobtco/storage_unit.svg
[2]: https://img.shields.io/coveralls/dobtco/storage_unit.svg
[3]: https://img.shields.io/gem/v/storage_unit.svg
