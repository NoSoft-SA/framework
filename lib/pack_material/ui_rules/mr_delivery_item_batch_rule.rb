# frozen_string_literal: true

module UiRules
  class MrDeliveryItemBatchRule < Base
    def generate_rules
      @repo = PackMaterialApp::ReplenishRepo.new
      @print_repo = LabelApp::PrinterRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_print_fields if @mode == :print_barcode

      form_name 'mr_delivery_item_batch'
    end

    private

    def set_show_fields
      fields[:client_batch_number] = { renderer: :label }
      fields[:quantity_on_note] = { renderer: :label }
      fields[:quantity_received] = { renderer: :label }
    end

    def set_print_fields
      fields[:sku_number] = { renderer: :label }
      fields[:product_variant_code] = { renderer: :label }
      fields[:batch_number] = { renderer: :label }
      fields[:printer] = { renderer: :select,
                           options: @print_repo.select_printers_for_application(AppConst::PRINT_APP_MR_SKU_BARCODE),
                           required: true }
      fields[:no_of_prints] = { renderer: :integer, required: true }
    end

    def common_fields
      {
        mr_delivery_item_id: { renderer: :hidden },
        client_batch_number: {},
        quantity_on_note: { renderer: :numeric, required: true },
        quantity_received: { renderer: :numeric, required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new
      form_object_for_barcode_print && return if @mode == :print_barcode

      @form_object = @repo.find_mr_delivery_item_batch(@options[:id])
    end

    def form_object_for_barcode_print
      rec = @repo.sku_for_barcode(@options[:id])
      @form_object = OpenStruct.new(rec.merge(printer: @print_repo.default_printer_for_application(AppConst::PRINT_APP_MR_SKU_BARCODE)))
    end

    def make_new_form_object
      item = mr_delivery_item
      @form_object = OpenStruct.new(mr_delivery_item_id: item.id,
                                    client_batch_number: nil,
                                    quantity_on_note: item.quantity_on_note,
                                    quantity_received: item.quantity_received)
    end

    def mr_delivery_item
      @repo.find_mr_delivery_item(@options[:parent_id])
    end
  end
end
