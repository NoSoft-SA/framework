# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrPurchaseOrderCost
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_purchase_order_cost, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :mr_cost_type_id
              form.add_field :mr_purchase_order_id
              form.add_field :amount
            end
          end

          layout
        end
      end
    end
  end
end
