require_relative 'base'

module Orchestrator
  class NewSubmissionsTest < SystemBaseTestCase
    def test_posts_successfully
      application.add_language(:ruby, {"num_processors" => 0})

      uuid = "foobar"
      language_slug = "ruby"
      exercise_slug = "two-fer"

      post '/submissions', {
        submission_uuid: uuid,
        language_slug: language_slug,
        exercise_slug: exercise_slug
      }

      assert_equal 200, last_response.status

      assert_equal 1, application.queue_size(language: :ruby)
    end
  end
end
