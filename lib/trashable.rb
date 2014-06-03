require 'trashable/setup'
require 'trashable/core'
ActiveRecord::Base.send :include, Trashable::Setup
