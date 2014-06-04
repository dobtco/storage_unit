group :main do
  guard :rspec,
        all_on_start: false,
        all_after_pass: false,
        spec_paths: ['spec/']  do

    watch(%r{^lib/storage_unit/(.+)\.rb$})                           { |m| "spec/storage_unit_spec.rb" }
  end
end
