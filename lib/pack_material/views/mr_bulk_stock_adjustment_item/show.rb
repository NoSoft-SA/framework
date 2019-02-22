# frozen_string_literal: true

module PackMaterial
  module Transactions
    module MrBulkStockAdjustmentItem
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_bulk_stock_adjustment_item, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Mr Bulk Stock Adjustment Item'
              form.view_only!
              form.add_field :mr_bulk_stock_adjustment_id
              form.add_field :mr_sku_location_id
              form.add_field :sku_number
              form.add_field :product_variant_number
              form.add_field :product_number
              form.add_field :mr_type_name
              form.add_field :mr_sub_type_name
              form.add_field :product_variant_code
              form.add_field :product_code
              form.add_field :location_code
              form.add_field :inventory_uom_code
              form.add_field :scan_to_location_code
              form.add_field :system_quantity
              form.add_field :actual_quantity
              form.add_field :stock_take_complete
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
