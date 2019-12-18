require_relative 'base'

module Orchestrator
  class StatusTest < SystemBaseTestCase
    def test_status
      stub_platform_connection!(times: 5)
      stub_language_processor_run!(times: 5)

      application.add_language(:ruby, {'timeout_ms' => '100', 'container_slug' => 'cv_ruby', 'num_processors' => 2})
      application.add_language(:javascript, {'timeout_ms'=> '200', 'container_slug' => 'cv_js', 'num_processors' => 3})
      application.add_language(:csharp, {'timeout_ms'=> '300', 'container_slug' => 'cv_c#', 'num_processors' => 0})

      application.enqueue_submission(1, :ruby, :two_fer)
      application.enqueue_submission(2, :ruby, :two_fer)
      application.enqueue_submission(3, :javascript, :two_fer)
      application.enqueue_submission(4, :javascript, :two_fer)
      application.enqueue_submission(5, :csharp, :two_fer)

      get "/status"
      assert_equal 200, last_response.status

      expected = {
        ruby: {
          num_processors: 2,
          queue_size: 2,
          settings: {
            timeout_ms: 100,
            container_slug: "cv_ruby"
          }
        },
        javascript: {
          num_processors: 3,
          queue_size: 2,
          settings: {
            timeout_ms: 200,
            container_slug: "cv_js"
          }
        },
        csharp: {
          num_processors: 0,
          queue_size: 1,
          settings: {
            timeout_ms: 300,
            container_slug: "cv_c#"
          }
        }
      }.to_json
      assert_equal expected, last_response.body
    end
  end
end

