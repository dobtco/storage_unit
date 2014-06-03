trashable
=========

:recycle:

Soft deletion for Rails 4.1+, done right.

### Goals

- Standard set of "soft deletion" methods (`trash`, `recover`, `trashed?`)
- Explicit trashable dependencies (automatically trash associated records)
- Low-overhead (minimize queries)
- No validations on `recover`. (If your records became invalid after they were trashed, check for this yourself)
- Small, readable codebase

### Non-goals

- Targeting anything less than Rails 4.1
- Reflection on Rails' associations
- Generally, anything weird or complex happening behind the scenes

### Usage

```ruby
# Table name: posts
#
#  id              :integer
#  deleted_at      :datetime

class Post < ActiveRecord::Base
  trashable
end

p = Post.create
Post.all # => [p]
p.trashed? # => false

p.trash!
p.trashed? # => true
Post.all # => []
Post.with_deleted.all # => [p]

p.recover!
p.trashed? # => false
Post.all # => []
```

### Cascading trashes

```ruby
class User < ActiveRecord::Base
  trashable, cascade: [:posts]
  has_many :posts
end

class Post < ActiveRecord::Base
  trashable
end

u = User.create
p = Post.create

u.trash!
u.trashed? # => true
p.trashed? # => true

u.recover!
u.trashed? # => false
p.trashed? # => false
```

### Callbacks

```ruby
class Post < ActiveRecord::Base
  trashable
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
  trashable column: :trashed_at
end
```
