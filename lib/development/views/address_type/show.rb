# frozen_string_literal: true

module Development
  module Masterfiles
    module AddressType
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:address_type, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :address_type
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
