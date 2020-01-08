require_relative 'base'

module Orchestrator
  class BuildVersionTest < SystemBaseTestCase
    def test_build_version
      PlatformConnection.any_instance.expects(:build_version).with("ruby", "foobar123")

      post '/languages/ruby/versions', {
        version: {
          slug: "foobar123",
        }
      }

      assert_equal 200, last_response.status
    end
  end
end
