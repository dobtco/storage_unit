module StorageUnit
  module Core
    extend ActiveSupport::Concern

    included do
      default_scope { where(default_scope_hash) }
      define_model_callbacks :trash
      define_model_callbacks :recover
    end

    module ClassMethods
      def default_scope_hash
        { storage_unit_opts[:column] => nil }
      end

      def with_deleted
        self.all.unscope(where: storage_unit_opts[:column])
      end

      def deleted_only
        with_deleted.where.not(default_scope_hash)
      end
    end

    def trashed?
      send(storage_unit_opts[:column]).present?
    end

    def trash!
      run_callbacks :trash do
        update_columns trash_hash(DateTime.now)
        trash_dependents
      end
    end

    def trash_dependents
      Array(storage_unit_opts[:cascade]).each do |x|
        send(x).update_all trash_hash(DateTime.now)
      end
    end

    def recover!(opts = {})
      run_callbacks :recover do
        update_columns trash_hash(nil)
        recover_dependents
      end
    end

    def recover_dependents
      Array(storage_unit_opts[:cascade]).each do |x|
        send(x).with_deleted.update_all trash_hash(nil)
      end
    end

    def trash_hash(value)
      {}.tap { |h| h[storage_unit_opts[:column]] = value }
    end
  end
end
