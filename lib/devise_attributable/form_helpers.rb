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
      attribute_options = object.attributables[attribute]

      field_options = {
        required: attribute_options[:required],
        # TODO: This is actually just needed for registrations/edit...
        data: { 'update-requires-password' => object.send("#{attribute}_update_requires_current_password?") }
      }.merge(attribute_options[:field])

      # Remove the default values the model is not new.
      field_options.delete(:default) unless object.new_record?
      field_options.delete(:checked) unless object.new_record?

      field_type = field_options.delete(:type)

      self.send(field_type, attribute, field_options)
    end

    # Returns a login field based on what is configured in "Devise.authentication_keys".
    def devise_login(*args)
      options = args.extract_options!
      self.send(:text_field, devise_authentication_key, *(args << options))
    end

    # Returns the label for the login field.
    def devise_login_label(*args)
      options = args.extract_options!

      if devise_authentication_key == :login
        # Another options would be to create a translation for the virtual attribute
        # on the model like so:
        #   en: activerecord: attributes: user: login: Username or Email
        label = I18n.t('devise_attributable.authentication_label')
      else
        label = devise_authentication_key
      end

      self.send(:label, label, options)
    end

    private
      # Returns the field used for login.
      def devise_authentication_key
        if DeviseAttributable.authenticate_via_username_or_email?
          :login
        else
          Devise.authentication_keys.first.to_sym
        end
      end
  end
end
