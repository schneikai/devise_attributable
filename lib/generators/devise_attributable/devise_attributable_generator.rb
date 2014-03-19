module DeviseAttributable
  module Attributable
    class DeviseAttributableGenerator < Rails::Generators::NamedBase
      namespace "devise_attributable"
      desc "Generate migrations for DeviseAttributable configuration."

      hook_for :orm
    end
  end
end
