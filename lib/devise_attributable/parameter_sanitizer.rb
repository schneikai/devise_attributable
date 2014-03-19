# Add all attributables to the Devise parameter sanitizer.

module DeviseAttributable
  module ParameterSanitizer
    extend ActiveSupport::Concern

    included do
      before_filter :update_devise_attributable_sanitized_params, if: :update_devise_attributable_sanitized_params?
    end

    def update_devise_attributable_sanitized_params
      resource = resource_class.new

      # :sign_in defaults
      #   auth_keys + [:password, :remember_me]

      # :sign_up defaults
      #   auth_keys + [:password, :password_confirmation]
      devise_parameter_sanitizer.for(:sign_up).concat([:username, :email]) if DeviseAttributable.authenticate_via_username_or_email?

      # :account_update defaults
      #   auth_keys + [:password, :password_confirmation, :current_password]
      devise_parameter_sanitizer.for(:account_update).concat([:username, :email]) if DeviseAttributable.authenticate_via_username_or_email?

      # Parameters for :sign_up and :account_update.
      [:sign_up, :account_update].each do |action|
        resource.attributables.keys.each do |name|
          devise_parameter_sanitizer.for(action) << name
        end
      end
    end

    private
      def update_devise_attributable_sanitized_params?
        devise_controller? && devise_mapping.attributable?
      end
  end
end
