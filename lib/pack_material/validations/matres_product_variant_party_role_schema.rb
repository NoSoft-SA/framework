# frozen_string_literal: true

module PackMaterialApp
  class NewMatresProductVariantPartyRoleContract < Dry::Validation::Contract
    params do
      optional(:id).filled(:integer)
      required(:material_resource_product_variant_id).filled(:integer)
      optional(:supplier_id).maybe(:integer)
      optional(:customer_id).maybe(:integer)
      required(:party_stock_code).filled(Types::StrippedString)
      optional(:supplier_lead_time).filled(:integer)
      optional(:is_preferred_supplier).filled(:bool)
    end

    rule(:customer_id, :supplier_id) do
      base.failure('must provide either customer or supplier') unless values[:customer_id] || values[:supplier_id]
    end
  end

  # NewMatresProductVariantPartyRoleSchema = Dry::Schema.Params do
  #   configure do
  #     config.type_specs = true
  #
  #     def self.messages
  #       super.merge(en: { errors: { customer_or_supplier: 'must provide either customer or supplier' } })
  #     end
  #   end
  #
  #   optional(:id, :integer).filled(:int?)
  #   required(:material_resource_product_variant_id, :integer).filled(:int?)
  #   optional(:supplier_id, :integer).maybe(:int?)
  #   optional(:customer_id, :integer).maybe(:int?)
  #   required(:party_stock_code, Types::StrippedString).filled(:str?)
  #   optional(:supplier_lead_time, :integer).filled(:int?)
  #   optional(:is_preferred_supplier, :bool).filled(:bool?)
  #
  #   validate(customer_or_supplier: %i[customer_id supplier_id]) do |customer_id, supplier_id|
  #     customer_id || supplier_id
  #   end
  # end

  UpdateMatresProductVariantPartyRoleSchema = Dry::Schema.Params do
    optional(:id).filled(:integer)
    required(:material_resource_product_variant_id).filled(:integer)
    optional(:supplier_id).maybe(:integer)
    optional(:customer_id).maybe(:integer)
    required(:party_stock_code).filled(Types::StrippedString)
    optional(:supplier_lead_time).maybe(:integer)
    optional(:is_preferred_supplier).filled(:bool)
  end
end
