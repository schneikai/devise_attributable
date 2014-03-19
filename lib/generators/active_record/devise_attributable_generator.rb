require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class DeviseAttributableGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def create_migrations
        unless attributables?
          warn "[WARNING] No attributables configured. Please check the README on how to do this."
          return false
        end

        migration_template "migrations.rb", "db/migrate/devise_attributable_add_fields_to_#{table_name}"
      end

      private
        def attributables
          DeviseAttributable.attributables
        end

        # Returns true if attributables are configured.
        def attributables?
          attributables.any?
        end

        # Returns the column configuration for each attributable.
        def columns
          columns = {}
          attributables.each do |name, options|
            columns[name] = options[:migrations].except(:index)
          end
          columns.presence
        end

        # Returns the index configuration for each attributable.
        def indexes
          indexes = {}
          attributables.each do |name, options|
            if options[:migrations][:index]
              indexes[name] = options[:migrations][:index]
            end
          end
          indexes.presence
        end
    end
  end
end
