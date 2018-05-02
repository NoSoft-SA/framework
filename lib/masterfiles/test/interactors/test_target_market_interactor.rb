# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TestTargetMarketInteractor < Minitest::Test
    def test_repo
      target_market_repo = interactor.send(:target_market_repo)
      assert target_market_repo.is_a?(MasterfilesApp::TargetMarketRepo)
    end

    private

    def interactor
      @interactor ||= TargetMarketInteractor.new(current_user, {}, {}, {})
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize