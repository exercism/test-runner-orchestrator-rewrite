require_relative 'base'

module Orchestrator
  class ScaleProcessorsTest < SystemBaseTestCase
    def test_updates_successfully
      stub_platform_connection!(times: 1)

      application = Orchestrator.application
      application.add_language(:ruby, {"num_processors" => 1})
      assert_equal 1, application.num_processors(language: :ruby)

      stub_platform_connection!(times: 4)

      patch '/languages/ruby/scale/5', {}
      assert_equal 200, last_response.status
      assert_equal 5, application.num_processors(language: :ruby)
    end
  end
end
