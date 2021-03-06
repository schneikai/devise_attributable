module DeviseAttributable
  module FormHelpers
    # Returns a field for a given attributable.
    # I'm not very happy with the name. Something like "attributable_field" or
    # "devise_field" would be better but in Hive I use TwitterBootstrapFormFor and
    # it works by overwriting form helpers ending with "_field" in the name and
    # we would end up with two labels because we call "text_field" here for example.
    # Same for the naming of "devise_login" vs "devise_login_field".
    def attributable(*args)
      options = args.extract_options!
      attribute = args.shift

      field_options = attributable_options(attribute)
      field_type = field_options.delete(:type)

      if simple_form?
        self.input attribute, field_options
      else
        self.send(field_type, attribute, field_options)
      end
    end

    # Returns a login field based on what is configured in "Devise.authentication_keys".
    def devise_login(*args)
      options = args.extract_options!
      if simple_form?
        self.input devise_authentication_key, *(args << options)
      else
        self.send(:text_field, devise_authentication_key, *(args << options))
      end
    end

    # Returns the label for the login field.
    def devise_login_label(*args)
      options = args.extract_options!

      if devise_authentication_key == :login
        # Another option would be to create a translation for the virtual attribute
        # on the model like so:
        #   en: activerecord: attributes: user: login: Username or Email
        label = I18n.t('devise_attributable.authentication_label')
      else
        label = devise_authentication_key
      end

      self.send(:label, label, options)
    end

    private
      # Returns input field options for the given attribute.
      def attributable_options(attribute)
        # Get configured field options from model.
        options = object.attributables[attribute][:field]

        # Add some more options...
        options[:data] ||= {}
        options[:required] = object.send("#{attribute}_required?")
        options[:data]['update-requires-password'] = object.send("#{attribute}_update_requires_current_password?") unless object.new_record?

        # Remove the default values if the model is not new.
        unless object.new_record?
          options.delete(:default)
          options.delete(:checked)
        end

        # In SimpleForm data attributes must go under *input_html* key.
        options[:input_html] = { data: options.delete(:data) } if simple_form?

        options
      end

      # Returns the field used for login.
      def devise_authentication_key
        if DeviseAttributable.authenticate_via_username_or_email?
          :login
        else
          Devise.authentication_keys.first.to_sym
        end
      end

      def simple_form?
        self.class.name == 'SimpleForm::FormBuilder' || self.class.name == 'Hive::FormBuilder'
      end
  end
end
