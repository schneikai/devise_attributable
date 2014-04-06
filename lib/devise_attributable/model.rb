module Devise
  module Models
    module Attributable
      extend ActiveSupport::Concern

      # I had to mo everything into a included block because we need the attributables
      # configuration from the initializer this wasn't available outside the inlcuded block...
      included do
        attr_accessor :login if DeviseAttributable.authenticate_via_username_or_email?

        # I had to move the creation of attributes and validation into
        # the included block because it needs the *attributes* configuration from
        # the initializer and this is not yet available when the file is required
        # but was available when the included block was run.
        DeviseAttributable.attributables.each do |name,options|
          # Returns +true+ if the attribute is required. Otherwise +false+.
          define_method "#{name}_required?" do
            !!options[:required]
          end

          # Returns +true+ if the field requires the current password for update.
          # Otherwise +false+.
          define_method "#{name}_update_requires_current_password?" do
            attributable_update_requires_current_password? name
          end

          # Add validators
          if options[:validators]
            options[:validators].each do |validator_name,validator_options|
              class_eval <<-RUBY, __FILE__, __LINE__
                #{validator_name} :#{name}#{DeviseAttributable.to_options(validator_options)}
              RUBY
            end
          end
        end
      end

      def attributables
        DeviseAttributable.attributables
      end

      # Returns +true+ if any attribute in +params+ requires the current password
      # when updated. Otherwise +false+.
      def update_requires_current_password?(params)
        DeviseAttributable.update_requires_current_password?(self, params)
      end

      # Returns +true+ if the given attribute requires the current password when updated.
      # Otherwise +false+.
      def attributable_update_requires_current_password?(name)
        DeviseAttributable.attributable_update_requires_current_password?(self, name)
      end

      module ClassMethods
        def find_first_by_auth_conditions(warden_conditions)
          if DeviseAttributable.authenticate_via_username_or_email?
            conditions = warden_conditions.dup
            if login = conditions.delete(:login)
              where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
            else
              where(conditions).first
            end
          else
            super
          end
        end
      end

    end
  end
end
