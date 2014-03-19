class DeviseAttributableAddFieldsTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
<% columns.each do |name,options| -%>
    add_column :<%= table_name %>, :<%= name %>, :<%= options[:format] %><%= DeviseAttributable.to_options(options.except(:format)) %>
<% end -%>

<% indexes.each do |name,options| -%>
    add_index :<%= table_name %>, :<%= name %><%= DeviseAttributable.to_options(options) %>
<% end -%>
  end
end
