# frozen_string_literal: true

module PackMaterialApp
  class CreateDeliverySKUS < BaseService
    def initialize(mr_delivery_id, user_name)
      @id = mr_delivery_id
      @repo = MrStockRepo.new
      @delivery = @repo.find_mr_delivery(@id)
      @user_name = user_name
    end

    def call
      return failed_response('Delivery record does not exist') unless @delivery

      sku_ids = @repo.create_skus_for_delivery(@id)
      @repo.log_status('mr_deliveries', @id, 'SKUS_CREATED')
      business_process_id = @repo.resolve_business_process_id(delivery_id: @id)

      CreateMrStock.call(sku_ids, business_process_id, to_location_id: @delivery.receipt_location_id, delivery_id: @id, user_name: @user_name)
    end
  end
end