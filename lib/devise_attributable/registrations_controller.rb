# Extensions for the devise registrations controller.

module DeviseAttributable
  module RegistrationsController
    extend ActiveSupport::Concern

    included do
      alias_method :update_resource, :update_resource_conditional
    end

    protected
      # Devise by default requires a password on update.
      # We overwrite this method and check the params if there is anything in
      # that requires the current password.
      def update_resource_conditional(resource, params)
        if resource.update_requires_current_password?(params)
          resource.update_with_password(params)
        else
          params.delete(:current_password)
          resource.update_without_password(params)
        end
      end
  end
end
