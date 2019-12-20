require_relative 'base'

module Orchestrator
  class DeployVersionTest < SystemBaseTestCase
    def test_deploy_version
      PlatformConnection.any_instance.expects(:deploy_version).with("ruby", "foobar123")

      patch '/languages/ruby/versions/foobar123/deploy', {}

      assert_equal 200, last_response.status
    end
  end
end

