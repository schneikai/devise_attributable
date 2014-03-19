# DeviseAttributable

With DeviseAttributable you can easily add extra attributes (aka "attributables")
like a username or a address to your [Devise](https://github.com/plataformatec/devise)
model. It works by reading form simple configuration and add migrations,
parameter sanatizers and validations to Devise which would usually require you to
change a lot of file.

It also adds a option to allow login with username and/or email.

DeviseAttributable supports Rails 4 and Devise 3.


## Installation

You must have installed and configured Devise first. Follow the guides on
https://github.com/plataformatec/devise.

Add DeviseAttributable to your Gemfile and run the bundle command to install it:

```ruby
gem 'devise_attributable'
```

After the Gem is installed you need to run the install generator:

```console
rails generate devise_attributable:install
```

This will add the DeviseAttributable module to Devise, include the required javascript
and stylesheets in your application and add configuration options to the Devise initializer.

Now open the Devise initializer <tt>config/initializers/devise.rb</tt>, search for
the "Configuration for :attributable" and add the attributes you want
to for your Devise model like this:

```ruby
config.attributables = [ :username, :company, :first_name, :last_name, :newsletter ]
```

This would add a username, company, first name, last name and newsletter attribute
with some sensible defaults. For Example the username will be required and must be
unique, the newsletter field will render as a check box. The full configuration for
the attributes above would look like this:

```ruby
config.attributables = [
  { username: {
      required: true,
      field: {
        type: :text_field
      },
      validators: {
        validates_presence_of: { if: :username_required? },
        validates_uniqueness_of: { allow_blank: true, case_sensitive: false, if: :username_changed? }
      },
      migrations: {
        format: :string,
        unique: true,
        index: { unique: true }
      }
    }
  },
  { company: {
      required: false,
      field: {
        type: :text_field
      },
      validators: { },
      migrations: {
        format: :string
      }
    }
  },

  # "first_name" and "last_name" are the same like "company"

  { newsletter: {
      required: false,
      field: {
        type: :check_box,
        checked: true
      },
      validators: { },
      migrations: {
        format: :boolean
      }
    }
  }
]
```

When you are done with your configuration you need to generate a migration for
this configuration by running the following generator and migrate your database:

```console
rails generate devise_attributable User
rake db:migrate
```

Replace *User* with the name of you Devise model if it is not *User*. If you need
to modify the attributables configuration for example if you made a mistake or if
you want to add more attributes just check "Add or change attributes" in this README.


## Integration in your Rails App

To include the new fields when signing up or editing the account we need to
modify the Devise templates for <tt>registrations#edit</tt>, <tt>registrations#new</tt>
and <tt>sessions#new</tt> a little. If you haven't modified the default Devise templates
and didn't use <tt>rails generate devise:views</tt> all should work out of the box
because the templates are modified by this Gem. But if you have generated the Devise
views in your app this is what you have to to:

In <tt>app/views/devise/registrations/new.html.erb</tt> add the following to the form:

```ruby
<% attributables(resource, optional: false).each do |name, options| %>
  <div><%= f.label name %><br />
  <%= f.attributable name %></div>
<% end %>
```

This will render fields for configured attributables except optional attributes.
Other options are:
  * <tt>with: [symbol or array of symbols]</tt> - Return this attributes even if they are optional.
  * <tt>only: [symbol or array of symbols]</tt> - Return only this attributes.
  * <tt>except: [symbol or array of symbols]</tt> - Never return this attributes.

In <tt>app/views/devise/registrations/edit.html.erb</tt> add the following to the form:

```ruby
<% attributables(resource).each do |name, options| %>
  <div><%= f.label name %><br />
  <%= f.attributable name %></div>
<% end %>
```

This will render fields for all attributables.

In <tt>app/views/devise/sessions/new.html.erb</tt> remove the label and field for email and add:

```ruby
<div><%= f.devise_login_label %><br />
<%= f.devise_login :autofocus => true %></div>
```


## Login with username or email

By default login in devise works via a email address and a password. When you use
DeviseAttributable and you add a username to your devise model you might want to use
that username for login instead of the email. To do this go to your devise initializer
in <tt>config/initializers/devise.rb</tt> and set

```ruby
config.authentication_keys = [ :username ]
```

If you want your users to login with either their usernames or their email addresses
you can do this by changing the setting in the initializer to

```ruby
config.authentication_keys = [ :login ]
```

Make sure you modified the <tt>sessions#new</tt> template as show above to show
the new login field.


## Update account with or without password

By default whenever a user updates his account, change his email for example, we
needs type in his current password. If you don't like this you can specify what
should be updateable without the current password and what not. Check the Devise
initializer for the config entry <tt>attributables_updateable_without_password</tt>.

You can also dynamically show and hide the current password field via javascript
in the registrations#edit form whenever or not it is required. To do this:

  * add <tt>data-update-requires-password=true</tt> to any field that requires a
    password when changed. This is added automatically when you use the
    *attributable* form helper.
  * wrap the current password field in a div with <tt>id=current-password-container</tt>


## Add or change attributes

If you want to add more attributes later just update the <tt>config.attributables</tt>
configuration in the Devise initializer and run:

  TODO: We need to create a generator that checks what attributes where added
  or changed and then create migration for the missing attributes or update other.


## Translations

DeviseAttributable uses the following [locales](https://github.com/schneikai/devise_attributable/blob/master/config/locales).
Add or change translations by adding or overwriting these files in your app.


## TODO
* add tests!
* when authkey :login is specified but :username is not present maybe we should show a little error message?
* add option to lock the username? (never change, change after 7 days, 3times, ...)
* update gemspec description and summary
* this is not tested to work for multiple Devise models.


## Licence

MIT-LICENSE. Copyright 2014 Kai Schneider.
