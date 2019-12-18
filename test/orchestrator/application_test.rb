require 'test_helper'

module Orchestrator
  class ApplicationTest < Minitest::Test
    def test_enqueue_submission_proxies
      application = Application.new
      application.add_language(:ruby, {'num_processors' => 0})
      application.add_language(:javascript, {'num_processors' => 0})

      application.enqueue_submission(1, :ruby, :two_fer)
      assert_equal 1, application.queue_size(language: :ruby)
      assert_equal 0, application.queue_size(language: :javascript)

      application.enqueue_submission(2, :ruby, :two_fer)
      assert_equal 2, application.queue_size(language: :ruby)
      assert_equal 0, application.queue_size(language: :javascript)

      application.enqueue_submission(3, :javascript, :two_fer)
      assert_equal 2, application.queue_size(language: :ruby)
      assert_equal 1, application.queue_size(language: :javascript)
    end

    # This whole test is horrible in terms of checking
    # internals but it's also caught lots of integration
    # errors between all the pieces so I'm ok with it for now.
    def test_add_language_proxies
      stub_platform_connection!(times: 6)
      stub_language_processor_run!(times: 6)

      application = Application.new
      application.add_language(:ruby, {'num_processors' => 0})
      application.add_language(:javascript, {'num_processors' => 1})
      application.add_language(:csharp, {'num_processors' => 1})

      assert_equal 0, application.num_processors(language: :ruby)
      assert_equal 1, application.num_processors(language: :javascript)
      assert_equal 1, application.num_processors(language: :csharp)

      application.scale_processors(language: :ruby, count: 3)
      application.scale_processors(language: :javascript, count: 2)

      assert_equal 3, application.num_processors(language: :ruby)
      assert_equal 2, application.num_processors(language: :javascript)
      assert_equal 1, application.num_processors(language: :csharp)
    end

    # This is a pretty ugly test, testing internals of things
    # but I think it's worth having as a sanity test for us.
    def test_settings
      timeout_ms = 213412432
      container_version = "asdasdsadas"

      application = Application.new
      application.add_language(:ruby, {
        'timeout_ms' => timeout_ms,
        'container_version' => container_version,
        'num_processors' => 0
      })

      application.send(:borrow_language, :ruby) do |lang|
        assert_equal timeout_ms, lang.settings.timeout_ms
        assert_equal container_version, lang.settings.container_version
      end

      new_timeout_ms = 987663
      new_container_version = "pooeioeqeq"

      application.update_language_settings(:ruby, {
       "timeout_ms" => new_timeout_ms,
       "container_version" => new_container_version
      })

      application.send(:borrow_language, :ruby) do |lang|
        assert_equal new_timeout_ms, lang.settings.timeout_ms
        assert_equal new_container_version, lang.settings.container_version
      end
    end

    def test_status
      stub_platform_connection!(times: 5)
      stub_language_processor_run!(times: 5)

      application = Application.new
      application.add_language(:ruby, {'timeout_ms' => '100', 'container_version' => 'cv_ruby', 'num_processors' => 2})
      application.add_language(:javascript, {'timeout_ms'=> '200', 'container_version' => 'cv_js', 'num_processors' => 3})
      application.add_language(:csharp, {'timeout_ms'=> '300', 'container_version' => 'cv_c#', 'num_processors' => 0})

      application.enqueue_submission(1, :ruby, :two_fer)
      application.enqueue_submission(2, :ruby, :two_fer)
      application.enqueue_submission(3, :javascript, :two_fer)
      application.enqueue_submission(4, :javascript, :two_fer)
      application.enqueue_submission(5, :csharp, :two_fer)

      expected = {
        ruby: {
          num_processors: 2,
          queue_size: 2,
          settings: {
            timeout_ms: 100,
            container_version: "cv_ruby"
          }
        },
        javascript: {
          num_processors: 3,
          queue_size: 2,
          settings: {
            timeout_ms: 200,
            container_version: "cv_js"
          }
        },
        csharp: {
          num_processors: 0,
          queue_size: 1,
          settings: {
            timeout_ms: 300,
            container_version: "cv_c#"
          }
        }
      }
      assert_equal expected, application.status
    end

    # This whole test is horrible in terms of checking
    # internals but it's also caught lots of integration
    # errors between all the pieces so I'm ok with it for now.
    def test_add_language_proxies
      stub_platform_connection!(times: 6)
      stub_language_processor_run!(times: 6)

      application = Application.new
      application.add_language(:ruby, {'num_processors' => 0})
      application.add_language(:javascript, {'num_processors' => 1})
      application.add_language(:csharp, {'num_processors' => 1})

      assert_equal 0, application.num_processors(language: :ruby)
      assert_equal 1, application.num_processors(language: :javascript)
      assert_equal 1, application.num_processors(language: :csharp)

      application.scale_processors(language: :ruby, count: 3)
      application.scale_processors(language: :javascript, count: 2)

      assert_equal 3, application.num_processors(language: :ruby)
      assert_equal 2, application.num_processors(language: :javascript)
      assert_equal 1, application.num_processors(language: :csharp)
    end

  end
end
