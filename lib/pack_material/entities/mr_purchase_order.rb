# frozen_string_literal: true

module PackMaterialApp
  class MrPurchaseOrder < Dry::Struct
    attribute :id, Types::Integer
    attribute :mr_delivery_term_id, Types::Integer
    attribute :account_code_id, Types::Integer
    attribute :supplier_party_role_id, Types::Integer
    attribute :mr_vat_type_id, Types::Integer
    attribute :delivery_address_id, Types::Integer
    attribute? :purchase_account_code, Types::String.optional
    attribute :fin_object_code, Types::String
    attribute :valid_until, Types::DateTime
    attribute :purchase_order_number, Types::Integer
    attribute :approved, Types::Bool
    attribute :short_supplied, Types::Bool
    attribute :deliveries_received, Types::Bool
    attribute :is_consignment_stock, Types::Bool
    attribute :status, Types::String
    attribute :remarks, Types::String
  end
end
