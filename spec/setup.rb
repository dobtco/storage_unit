ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.datetime :deleted_at
    t.datetime :trashed_at
  end

  create_table :notes do |t|
    t.integer :user_id
    t.datetime :deleted_at
    t.text :body
  end
end
