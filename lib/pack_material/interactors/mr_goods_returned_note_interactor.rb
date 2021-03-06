# frozen_string_literal: true

module PackMaterialApp
  class MrGoodsReturnedNoteInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
    def create_mr_goods_returned_note(params) # rubocop:disable Metrics/AbcSize
      res = validate_new_mr_goods_returned_note_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_mr_goods_returned_note(res.to_h.merge(created_by: @user.user_name))
        log_status('mr_goods_returned_notes', id, 'CREATED')
        log_transaction
      end
      instance = mr_goods_returned_note(id)
      success_response("Created Goods Returned Note CN No:#{instance.credit_note_number}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This Goods Returned Note already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_goods_returned_note(id, params)
      res = validate_mr_goods_returned_note_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_mr_goods_returned_note(id, res)
        log_transaction
      end
      instance = mr_goods_returned_note(id)
      success_response("Updated Goods Returned Note CN No: #{instance.credit_note_number}", instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_goods_returned_note(id)
      number = mr_goods_returned_note(id).credit_note_number
      repo.transaction do
        repo.delete_mr_goods_returned_note(id)
        log_status('mr_goods_returned_notes', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted Goods Returned Note CN No: #{number}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def ship_mr_goods_returned_note(id) # rubocop:disable Metrics/AbcSize
      assert_permission!(:can_ship, id)
      repo.transaction do
        res = validate_grn_stock_levels(id)
        return res unless res.success

        repo.update_with_document_number('doc_seqs_credit_note_number', id)
        grn = repo.find_mr_goods_returned_note(id)
        loc_id = grn.dispatch_location_id
        issue_id = nil
        attrs = {
          business_process_id: repo.grn_business_process_id,
          user_name: @user.user_name,
          parent_transaction_id: issue_id,
          ref_no: grn.credit_note_number
        }
        items = res.instance
        items.each do |item|
          attrs[:parent_transaction_id] = issue_id
          result = PackMaterialApp::RemoveMrStock.call(item[:sku_id], loc_id, item[:qty], attrs)
          transaction_item_id = result.instance
          issue_id ||= TransactionsRepo.new.find_mr_inventory_transaction_item(transaction_item_id)&.mr_inventory_transaction_id
        end

        repo.mark_as_shipped(id)
        repo.update_delivery_grn_status(grn.mr_delivery_id)
        repo.update(:mr_goods_returned_notes, id, issue_transaction_id: issue_id)
        log_status('mr_goods_returned_notes', id, 'SHIPPED')
        log_transaction
      end
      number = mr_goods_returned_note(id)&.credit_note_number
      success_response("Goods Returned Note CN No: #{number} has been shipped")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def complete_invoice(id) # rubocop:disable Metrics/AbcSize
      assert_permission!(:complete_invoice, id)
      return success_response('GRN Purchase Invoice has already been Queued') if already_enqueued?(id)

      repo.transaction do
        PackMaterialApp::CompletePurchaseInvoice.call(@user.user_name, false, nil, mr_goods_returned_note_id: id)
        repo.update_weighted_average_costs(id)
        log_transaction
        instance = mr_goods_returned_note(id)
        success_response("GRN #{instance.credit_note_number}: Purchase Invoice Queued", instance)
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil)
      res = check_permission(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_permission(task, id = nil)
      TaskPermissionCheck::MrGoodsReturnedNote.call(task, id, current_user: @user)
    end

    def email_credit_note_defaults(id, user)
      # View Logic
      instance = mr_goods_returned_note(id)
      del_no = repo.find_hash(:mr_deliveries, instance[:mr_delivery_id])[:delivery_number]
      {
        to: nil,
        cc: user.email,
        subject: "Goods Returned Note: #{instance.credit_note_number} (DEL: #{del_no})"
      }
    end

    def goods_returned_note_item_options(id)
      repo.goods_returned_note_item_options(id)
    end

    private

    def repo
      @repo ||= DispatchRepo.new
    end

    def mr_goods_returned_note(id)
      repo.find_mr_goods_returned_note(id)
    end

    def validate_mr_goods_returned_note_params(params)
      MrGoodsReturnedNoteSchema.call(params)
    end

    def validate_new_mr_goods_returned_note_params(params)
      NewMrGoodsReturnedNoteSchema.call(params)
    end

    def validate_grn_stock_levels(grn_id)
      repo.validate_grn_stock_levels(grn_id)
    end

    def already_enqueued?(grn_id)
      PackMaterialApp::ERPPurchaseInvoiceJob.enqueued_with_args?(mr_goods_returned_note_id: grn_id)
    end
  end
end
