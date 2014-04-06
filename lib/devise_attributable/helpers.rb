module DeviseAttributable
  module Helpers
    # Returns all configured attributes.
    # This can be used in a template to build fields for all attributes.
    #
    # Options:
    # * optional = true|false - If false it will not return optional attributes.
    # * with = symbol|array of symbols - Return this attributes even if they are optional.
    # * only = symbol|array of symbols - Return only this attributes.
    # * except = symbol|array of symbols - Never return this attributes.
    #
    def attributables(resource, *args)
      options = args.extract_options!
      attributables = {}

      with = Array(options[:with]).map(&:to_sym)
      only = Array(options[:only]).map(&:to_sym)
      except = Array(options[:except]).map(&:to_sym)
      # Maybe...
      # order = Array(options[:order]).map(&:to_sym)

      resource.attributables.each do |name, opts|
        # Skip the field if it is optional and not explicitly listed in the
        # +include+ list and it does not have errors.
        # If a field has an error and you don't show it the user won't be able
        # to fix the error. This is also important to sign-up dialogs where a new
        # resource could already have data for example from a omniauth callback.
        # We still allow to hide even such fields with errors via +only+ and
        # +except+ because for example in Hive we use the +attributables+ method
        # twice in the same form to get a specific field order (newsletter checkbox
        # after password for example).
        next if options[:optional].is_a?(FalseClass) && !opts[:required] && !with.include?(name) && resource.errors[name].blank?
        # Skip the field if a +only+ list is present and the field is not listed...
        next if only.any? && !only.include?(name)
        # Skip the field if a +except+ list is present and the field is listed.
        next if except.any? && except.include?(name)

        attributables[name] = opts
      end
      attributables
    end
  end
end
