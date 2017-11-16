# frozen_string_literal: true

class DestinationCountry < Dry::Struct
  attribute :id, Types::Int
  attribute :destination_region_id, Types::Int
  attribute :country_name, Types::String
  attribute :region_name, Types::String
end
