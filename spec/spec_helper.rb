require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]

require 'rails/all'
require 'storage_unit'
require 'rspec/rails'
require_relative 'setup'

RSpec.configure do |c|
  c.use_transactional_fixtures = true
end
