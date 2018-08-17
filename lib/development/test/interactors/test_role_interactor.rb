# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module DevelopmentApp
  class TestRoleInteractor < Minitest::Test
    def test_repo
      repo = interactor.repo
      # repo = interactor.send(:repo)
      assert repo.is_a?(DevelopmentApp::RoleRepo)
    end

    private

    def interactor
      @interactor ||= RoleInteractor.new(current_user, {}, {}, {})
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
