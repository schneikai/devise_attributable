require 'devise'
require 'devise_attributable/devise'

module DeviseAttributable
  autoload :Model, 'devise_attributable/model'
  autoload :ParameterSanitizer, 'devise_attributable/parameter_sanitizer'
  autoload :Helpers, 'devise_attributable/helpers'
  autoload :FormHelpers, 'devise_attributable/form_helpers'
  autoload :RegistrationsController, 'devise_attributable/registrations_controller'
  autoload :VERSION, 'devise_attributable/version'

  def self.attributables
    attributables = {}
    Devise.attributables.each do |part|
      if part.is_a?(Hash)
        name = part.keys.first
        attributables[name] = default_options.deep_merge(part[name])
      else
        attributables[part] = default_options_for(part)
      end
    end
    attributables
  end

  def self.default_options_for(part)
    if self.respond_to?("default_options_for_#{part}")
      self.send "default_options_for_#{part}"
    else
      default_options
    end
  end

  # Default options for a attribute.
  def self.default_options
    {
      required: false,
      field: {
        # Maybe we can detect this via the migration format?
        type: :text_field
      },
      validators: { },
      migrations: {
        format: :string
      }
    }
  end

  # Default options for a username field.
  def self.default_options_for_username
    default_options.deep_merge({
      required: true,
      validators: {
        validates_presence_of: { if: :username_required? },
        validates_uniqueness_of: { allow_blank: true, case_sensitive: false, if: :username_changed? },
      },
      migrations: {
        unique: true,
        index: { unique: true }
      }
    })
  end

  # Default options for a newsletter field.
  def self.default_options_for_newsletter
    default_options.deep_merge({
      field: {
        type: :check_box,
        checked: true
      },
      migrations: {
        format: :boolean
      }
    })
  end

  def self.authenticate_via_username_or_email?
    Devise.authentication_keys.first.to_sym == :login
  end

  # Returns +true+ if a resource update requires the current password (has
  # changes on attributes that require the current password). Otherwise +false+.
  # Always returns true if the update params contain a password.
  def self.update_requires_current_password?(resource, update_params=nil)
    return true if update_params.include?('password') || update_params.include?('password_confirmation')

    params = update_params.except('current_password')
    params.delete('password')
    params.delete('password_confirmation')

    # Get all attributes that have changed.
    changed_resource = resource.clone
    changed_resource.assign_attributes(params)

    # Ignore changes that where just nil to '' (empty string).
    # In Rails when you save a form the params hash contain '' for a empty form
    # field and saving such fields will also change the db from null to ''.
    changed_attributes = changed_resource.changes.reject{|k,v| v[0].presence == v[1].presence}.keys

    # Remove everything from the list that is updateable without a password
    # and if the result is empty there is no params that require a password for update.
    (changed_attributes - Devise.attributables_updateable_without_password.map(&:to_s)).any?
  end

  # Returns +true+ if the given attribute requires the current password
  # for update. Otherwise +false+.
  def self.attributable_update_requires_current_password?(resource, name)
    !Devise.attributables_updateable_without_password.include?(name)
  end

  # Convert a hash to a string that can be used for as options dynamically
  # created methods (migrations for example).
  #
  #   to_options({ :unique => true, :index => "foo" })
  #   => ":unique => true, :index => \"foo\""
  #
  def self.to_options(options)
    return unless options.is_a?(Hash)
    return unless options.any?
    ", #{options.to_s}".gsub(/[{}]/, '').gsub(/\=>/, ' => ')
  end
end

require 'devise_attributable/engine'
