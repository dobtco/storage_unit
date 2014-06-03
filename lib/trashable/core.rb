module Trashable
  module Core
    extend ActiveSupport::Concern

    included do
      default_scope { where(with_deleted_scope_sql) }
      define_model_callbacks :trash
      define_model_callbacks :recover
    end

    module ClassMethods
      def with_deleted_scope_sql
        all.table[trashable_opts[:column]].eq(nil).to_sql
      end

      # lifted from acts_as_paranoid, works around https://github.com/rails/rails/issues/4306
      # with this in place Post.limit(10).with_deleted, will work as expected
      def with_deleted
        scope = self.all
        scope.where_values.delete(with_deleted_scope_sql)
        scope
      end
    end

    def trashed?
      send(trashable_opts[:column]).present?
    end

    def trash!
      run_callbacks :trash do
        update_columns trash_hash(DateTime.now)
        trash_dependents
      end
    end

    def trash_dependents
      trashable_opts[:also_trash].each do |x|
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
      trashable_opts[:also_trash].each do |x|
        send(x).with_deleted.update_all trash_hash(nil)
      end
    end

    def trash_hash(value)
      {}.tap { |h| h[trashable_opts[:column]] = value }
    end
  end
end
