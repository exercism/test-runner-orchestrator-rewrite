require_relative 'base'

module Orchestrator
  class DeployVersionTest < SystemBaseTestCase
    def test_deploy_version
      PlatformConnection.any_instance.expects(:deploy_versions).with("ruby", ['asd', 'cdf'])

      patch '/languages/ruby/versions/deploy', {
        version_slugs: [ 'asd', 'cdf' ]
      }

      assert_equal 200, last_response.status
    end
  end
end

