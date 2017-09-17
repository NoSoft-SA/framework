module Security
  module FunctionalAreas
    module Programs
      class Edit
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:programs, :edit, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/security/functional_areas/programs/#{id}/update"
              form.add_field :program_name
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
