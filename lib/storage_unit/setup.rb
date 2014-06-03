module StorageUnit
  module Setup
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def has_storage_unit(opts = {})
        cattr_accessor :storage_unit_opts

        self.storage_unit_opts = {
          column: :deleted_at,
          cascade: []
        }.merge(opts)

        include StorageUnit::Core
      end
    end
  end
end