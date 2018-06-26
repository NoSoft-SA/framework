# frozen_string_literal: true

module DevelopmentApp
  class UserInteractor < BaseInteractor
    def repo
      @repo ||= UserRepo.new
    end

    def user(id)
      repo.find_user(id)
    end

    def validate_new_user_params(params)
      UserNewSchema.call(params)
    end

    def validate_user_params(params)
      UserSchema.call(params)
    end

    def validate_change_user_params(params)
      UserChangeSchema.call(params)
    end

    def validate_change_password(params)
      UserPasswordSchema.call(params)
    end

    def prepare_password(user_validation)
      new_user = user_validation.to_h
      new_user[:password_hash] = BCrypt::Password.create(new_user.delete(:password))
      new_user.delete(:password_confirmation)
      new_user
    end

    def create_user(params)
      res = validate_new_user_params(params)
      return validation_failed_response(hide_passwords_in_validation_errors(res)) unless res.messages.empty?
      id = repo.create_user(prepare_password(res))
      instance = user(id)
      success_response("Created user #{instance.user_name}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { login_name: ['This user already exists'] }))
    end

    def update_user(id, params)
      res = validate_user_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.update_user(id, res)
      instance = user(id)
      success_response("Updated user #{instance.user_name}",
                       instance)
    end

    def delete_user(id)
      name = user(id).user_name
      res = repo.delete_or_deactivate_user(id)
      success_response("#{res.message} #{name}")
    end

    def change_user_password(id, params)
      return invalid_password unless matching_password?(id, params[:old_password])
      res = validate_change_user_params(params)
      return validation_failed_response(hide_passwords_in_validation_errors(res)) unless res.messages.empty?
      DB.transaction do
        repo.save_new_password(id, params[:password])
        log_transaction
      end
      instance = user(id)
      success_response('Your password has been changed', instance)
    end

    def set_user_password(id, params)
      # Force the user's password to the new value.
      res = validate_change_password(params)
      return validation_failed_response(hide_passwords_in_validation_errors(res)) unless res.messages.empty?
      DB.transaction do
        repo.save_new_password(id, params[:password])
        log_transaction
      end
      instance = user(id)
      success_response("Password for #{instance.user_name} has been changed", instance)
    end

    private

    def invalid_password
      validation_failed_response(OpenStruct.new(messages: { old_password: ['Incorrect password'] }))
    end

    def hide_passwords_in_validation_errors(res)
      new_res = res.to_h
      new_res[:messages] = {}
      res.errors.each do |e, m|
        new_res[:messages][e] = m.map do |t|
          if t.start_with?('must not be equal')
            'cannot be the same as the old password'
          elsif t.start_with?('must be equal')
            'must match the password'
          else
            t
          end
        end
      end
      OpenStruct.new(new_res)
    end

    def matching_password?(id, password)
      hs = repo.find_hash(:users, id)
      BCrypt::Password.new(hs[:password_hash]) == password
    end
  end
end
