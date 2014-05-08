//= require jquery.plugin
//= require_tree .

$(function() {
  // Attach the RequirePassword plugin.
  // We also attach to forms with id "edit_user" because this is the default
  // Devise form for registrations#edit.
  $('[data-behavior~=devise_attributable-password-required], form#edit_user').deviseAttributablePasswordRequired();
});
