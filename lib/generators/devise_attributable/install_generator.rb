module DeviseAttributable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Add DeviseAttributable module, add config options to the Devise initializer and include assets in your application."

      argument :model, type: :string, default: 'User', banner: 'User'
      class_option :initializer, type: :string, default: 'config/initializers/devise.rb', desc: 'Specify the Devise initializer path.', banner: 'config/initializers/devise.rb"'

      def add_module
        path = File.join("app", "models", "#{model.underscore}.rb")
        if File.exists?(path)
          inject_into_file(path, "attributable, :", :after => "devise :")
        else
          say_status "error", "Model not found. Expected to be #{path}.", :red
        end
      end

      def add_config_options_to_initializer
        initializer = options['initializer']

        if File.exist?(initializer)
          old_content = File.read(initializer)

          unless old_content.match(Regexp.new(/^\s# ==> Configuration for :attributable\n/))
            inject_into_file(initializer, :before => "  # ==> Configuration for :confirmable\n") do
<<-CONTENT
  # ==> Configuration for :attributable
  # You can ask your users to provide additional details.
  # Remember to create a migration when you add or remove something here.
  # Check the README on how to do that.
  # config.attributables = [ :username, :company, :first_name, :last_name, :address1, :address2, :zip, :city, :state, :country ]

  # When users update their account details they need to enter their current password.
  # If you have less important account details like maybe a post address or a birth date
  # and your users should be able to change that without entering their current password
  # all the time you can specify such keys here.
  # config.attributables_updateable_without_password = [ :company, :first_name, :last_name, :address1, :address2, :zip, :city, :state, :country ]

CONTENT
            end
          end
        end
      end

      def require_javascripts
        insert_into_file "app/assets/javascripts/application#{detect_js_format[0]}",
          "#{detect_js_format[1]} require devise_attributable\n", :after => "jquery_ujs\n"
      end

      private
        # Taken from
        # https://github.com/groundworkcss/groundworkcss-rails/blob/master/lib/groundworkcss/generators/install_generator.rb
        def detect_js_format
          return ['.js', '//='] if File.exist?('app/assets/javascripts/application.js')
          return ['.js.coffee', '#='] if File.exist?('app/assets/javascripts/application.js.coffee')
          return ['.coffee', '#='] if File.exist?('app/assets/javascripts/application.coffee')
          return false
        end

    end
  end
end
