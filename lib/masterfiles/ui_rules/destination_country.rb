# frozen_string_literal: true

module UiRules
  class DestinationCountry < Base
    def generate_rules
      @repo = DestinationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'destination_country'
    end

    def set_show_fields
      # destination_region_id_label = @repo.find_region(@form_object.destination_region_id)&.destination_region_name
      # fields[:destination_region_id] = { renderer: :label, with_value: destination_region_id_label }
      fields[:region_name] = { renderer: :label }
      fields[:country_name] = { renderer: :label }
    end

    def common_fields
      {
        destination_region_id: { renderer: :select, options: @repo.regions_for_select },
        country_name: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_country(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(destination_region_id: nil,
                                    country_name: nil)
    end
  end
end
