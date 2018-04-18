# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TestCommodityGroupInteractor < Minitest::Test
    def test_repo
      commodity_repo = interactor.send(:commodity_repo)
      assert commodity_repo.is_a?(MasterfilesApp::CommodityRepo)
    end

    private

    def interactor
      @interactor ||= CommodityInteractor.new(current_user, {}, {}, {})
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize