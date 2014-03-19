// A little helper that can be used on devise forms to show or hide the current
// password field whenever or not it is required.
// It does this by checking if fields with data attribute
// "update-requires-password=true" have changed and if they have changed it will
// show the current password field (must be in a container with id "current-password-toggle").

window.DeviseAttributable || (window.DeviseAttributable = {});

(function($) {
  DeviseAttributable.PasswordRequired = function(element, options) {
    var that = this;
    this.element = $(element); // Must be a form element!
    this.options = $.extend({}, this.defaults, this.element.data(), options);

    // Save the initial value of each input element.
    this.fields().each(function() {
      var field = $(this);
      field.data('initial-value', field.val());
    });

    // Initially hide the password field unless it has errors.
    if (!this.currentPasswordHasError()) {
      this.currentPasswordContainer().hide();
    }

    // When the form changes check if any field that was changed requires
    // the current password.
    this.element.off('change.DeviseAttributablePasswordRequired').on('change.DeviseAttributablePasswordRequired', function() {
      if (that.isPasswordRequired()) {
        that.showPasswordField();
      } else {
        that.hidePasswordField();
      }
    });
  };

  DeviseAttributable.PasswordRequired.prototype = {
    defaults: { },

    // Returns true if any field that requires the current password was changed.
    isPasswordRequired: function() {
      var that = this;
      var returns = false;

      this.fields().each(function() {
        if(that.hasFieldChanged($(this))) {
          returns = true;
          return false;
        }
      });
      return returns;
    },

    // Checks if a given field was changed.
    hasFieldChanged: function(field) {
      return field.data('initial-value') != field.val();
    },

    // Returns all fields that require the current password when changed.
    // That are fields with "data-update-requires-password=true" and any
    // password fields.
    fields: function() {
      return this.element.find('input[data-update-requires-password=true], input[type=password]');
    },

    showPasswordField: function() {
      this.currentPasswordContainer().slideDown();
    },

    hidePasswordField: function() {
      this.currentPasswordContainer().slideUp();
    },

    currentPasswordContainer: function() {
      return this.element.find('#current-password-container');
    },

    currentPasswordHasError: function() {
      return this.currentPasswordContainer().find('.has-error, .field_with_errors').length > 0;
    }
  };

  // Create the plugin.
  $.plugin('DeviseAttributablePasswordRequired', DeviseAttributable.PasswordRequired);
})(jQuery);
