require 'minitest/autorun'
require 'crossbeams/layout'
require 'yaml'
require 'dry-struct'
require 'dry-validation'

ENV['RACK_ENV'] = 'test'
require './config/environment'

module Types
  include Dry::Types.module
end
require './lib/repo_base'

root_dir = File.expand_path('../..', __FILE__)

Dir["#{root_dir}/helpers/**/*.rb"].each { |f| require f }
require './lib/crossbeams_responses'
require './lib/base_service'
require './lib/base_interactor'
require './lib/ui_rules'

Dir["#{root_dir}/lib/applets/*.rb"].each { |f| require f }

require 'minitest/hooks/test'
class MiniTestWithHooks < Minitest::Test
  include Minitest::Hooks

  def around
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) do
      super
    end
  end

  def around_all
    DB.transaction(rollback: :always) do
      super
    end
  end
end
