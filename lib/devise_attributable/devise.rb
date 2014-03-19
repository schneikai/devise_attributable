module Devise
  # Specify the additional attributes for Devise here.
  #
  # For example, if you want to add a username, a company, first and last name
  # and a checkbox for a newsletter subscription:
  #
  #  config.attributables = [ :username, :company, :first_name, :last_name, :newsletter ]
  #
  # This will add the attributes with some defaults. The full configuration
  # looks like this:
  #
  #   config.attributables = [
  #     { username: {
  #         required: true,
  #         field: {
  #           type: :text_field
  #         },
  #         validators: {
  #           validates_presence_of: { if: :username_required? },
  #           validates_uniqueness_of: { allow_blank: true, case_sensitive: false, if: :username_changed? }
  #         },
  #         migrations: {
  #           format: :string,
  #           unique: true,
  #           index: { unique: true }
  #         }
  #       }
  #     },
  #     { company: {
  #         required: false,
  #         field: {
  #           type: :text_field
  #         },
  #         validators: { },
  #         migrations: {
  #           format: :string
  #         }
  #       }
  #     },
  #
  #     # *first_name* and *last_name* are the same like *company*
  #
  #     { newsletter: {
  #         required: false,
  #         field: {
  #           type: :check_box,
  #           checked: true
  #         },
  #         validators: { },
  #         migrations: {
  #           format: :boolean
  #         }
  #       }
  #     }
  #   ]
  #
  # Don't forget to create a migration from your configuration if you add/remove
  # or change anything. Check the README for more information.
  #
  mattr_accessor :attributables
  @@attributables = [ ]

  # When users update their account details they need to enter their current password.
  # If you have less important account details like maybe a post address or a birth date
  # and your users should be able to change that without entering their current password
  # all the time you can specify such keys here.
  mattr_accessor :attributables_updateable_without_password
  @@attributables_updateable_without_password = [ ]
end

Devise.add_module :attributable, model: 'devise_attributable/model'
