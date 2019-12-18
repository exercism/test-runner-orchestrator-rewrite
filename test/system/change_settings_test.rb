require_relative 'base'

module Orchestrator
  class ChangeSettingsTest < SystemBaseTestCase
    def test_updates_successfully
      application = Orchestrator.application
      application.add_language(:ruby, {"num_processors" => 0})

      timeout = 30002
      version = "some version"

      patch '/languages/ruby/settings', {
        settings: {
          timeout_ms: timeout,
          container_slug: version
        }
      }

      assert_equal 200, last_response.status

      application.send(:borrow_language, :ruby) do |lang|
        assert_equal timeout, lang.settings.timeout_ms
        assert_equal version, lang.settings.container_slug
      end
    end
  end
end

