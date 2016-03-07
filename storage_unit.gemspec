$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "storage_unit/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "storage_unit"
  s.version = StorageUnit::VERSION

  s.required_ruby_version = Gem::Requirement.new('>= 2.0.0')
  s.authors = ['Adam Becker']
  s.summary = 'Soft deletion for Rails 4, done right.'
  s.email = 'adam@dobt.co'
  s.license = 'MIT'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {features,spec}/*`.split("\n")

  s.homepage = 'http://github.com/dobtco/storage_unit'

  s.add_dependency 'rails', '~> 4.1', '>= 4.1.0'

  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
end
