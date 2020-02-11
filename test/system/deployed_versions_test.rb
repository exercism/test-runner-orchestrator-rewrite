require_relative 'base'

module Orchestrator
  class DeployedVersionsTest < SystemBaseTestCase
    def test_deployed_versions
      platform_response = {
        "version_slugs": ["a2mwqw", "kk8766"]
      }
      Application.any_instance.expects(:deployed_versions).with(language: "ruby").returns(platform_response)

      get "/languages/ruby/versions/deployed"
      assert_equal 200, last_response.status

      expected = {
        "version_slugs": ["a2mwqw", "kk8766"]
      }.to_json
      assert_equal expected, last_response.body

      assert_equal 200, last_response.status
    end
  end
end