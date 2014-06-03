require 'storage_unit/setup'
require 'storage_unit/core'
ActiveRecord::Base.send :include, StorageUnit::Setup
