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
        next if options[:optional].is_a?(FalseClass) && !opts[:required] && !with.include?(name)
        next if only.any? && !only.include?(name)
        next if except.any? && except.include?(name)
        attributables[name] = opts
      end
      attributables
    end
  end
end
