module StorageUnit
  module Setup
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def trashable(opts = {})
        cattr_accessor :trashable_opts

        self.trashable_opts = {
          column: :deleted_at,
          cascade: []
        }.merge(opts)

        include StorageUnit::Core
      end
    end
  end
end