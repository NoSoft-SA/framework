# frozen_string_literal: true

module Settings
  module PackMaterialProducts
    module MaterialResourceType
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:material_resource_type, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/settings/pack_material_products/material_resource_types/#{id}"
              form.remote!
              form.method :update
              form.add_field :material_resource_domain_id
              form.add_field :type_name
            end
          end

          layout
        end
      end
    end
  end
end