# frozen_string_literal: true

class ContactMethodTypeInteractor < BaseInteractor
  def repo
    @repo ||= ContactMethodTypeRepo.new
  end

  def contact_method_type(cached = true)
    if cached
      @contact_method_type ||= repo.find(:contact_method_types, ContactMethodType, @id)
    else
      @contact_method_type = repo.find(:contact_method_types, ContactMethodType, @id)
    end
  end

  def validate_contact_method_type_params(params)
    ContactMethodTypeSchema.call(params)
  end

  def create_contact_method_type(params)
    res = validate_contact_method_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    @id = repo.create_contact_method_types(res.to_h)
    success_response("Created contact method type #{contact_method_type.contact_method_type}",
                     contact_method_type)
  end

  def update_contact_method_type(id, params)
    @id = id
    res = validate_contact_method_type_params(params)
    return validation_failed_response(res) unless res.messages.empty?
    repo.update_contact_method_types(id, res.to_h)
    success_response("Updated contact method type #{contact_method_type.contact_method_type}",
                     contact_method_type(false))
  end

  def delete_contact_method_type(id)
    @id = id
    name = contact_method_type.contact_method_type
    repo.delete_contact_method_types(id)
    success_response("Deleted contact method type #{name}")
  end
end
