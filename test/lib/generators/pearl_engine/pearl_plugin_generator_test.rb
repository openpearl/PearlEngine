require 'test_helper'
require 'generators/pearl_plugin/pearl_plugin_generator'

module PearlEngine
  class PearlPluginGeneratorTest < Rails::Generators::TestCase
    tests PearlPluginGenerator
    destination Rails.root.join('tmp/generators')
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
