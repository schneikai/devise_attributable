module DeviseAttributable
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) { include DeviseAttributable::ParameterSanitizer }
    ActiveSupport.on_load(:action_view) { include DeviseAttributable::Helpers }

    # We use to_prepare instead of after_initialize here because Devise is a
    # Rails engine and its classes are reloaded like the rest of the user's app.
    # Got to make sure that our methods are included each time.
    config.to_prepare do
      Devise::RegistrationsController.send :include, DeviseAttributable::RegistrationsController
      ActionView::Helpers::FormBuilder.send :include, DeviseAttributable::FormHelpers
    end
  end
end
