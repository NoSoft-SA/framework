# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestVehicleTypeInteractor < Minitest::Test
    def test_repo
      repo = interactor.repo
      # repo = interactor.send(:repo)
      assert repo.is_a?(PackMaterialApp::TripsheetsRepo)
    end

    private

    def interactor
      @interactor ||= VehicleTypeInteractor.new(current_user, {}, {}, {})
    end
  end
end
