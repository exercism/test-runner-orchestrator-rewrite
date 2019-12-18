require 'test_helper'

module Orchestrator
  class LanguageProcessorTest < Minitest::Test
    def test_runs_and_exits
      stub_platform_connection!

      queue = mock

      # TODO - Add a range of 9-11 here
      # This should be 1 / CHECK_FREQUENCY_MS.to_s
      queue.expects(:shift).at_least(9)

      language_processor = LanguageProcessor.new(queue, nil, nil)

      # Sleep for one second then exit.
      Thread.new do
        sleep(1)

        # Exit first so we dont make this flakey
        # sleep should be 2x CHECK_FREQUENCY_MS.to_s
        language_processor.exit!
        queue.expects(:shift).never
        sleep(0.2)
      end

      Thread.expects(:new).yields
      language_processor.send(:run!)
    end

    def test_works_with_handled_test_run
      stub_platform_connection!

      uuid = "023949s9dads"
      submission = Submission.new(uuid, :ruby, :bob)
      queue = Queue.new
      queue.push(submission)
      queue.expects(:push).never

      monitor = mock
      monitor.expects(:record!).with(uuid, 200)

      test_runner = stub_test_runner!
      test_runner.expects(:test!).returns([true, 200])

      with_language_processor(:ruby, queue, monitor, nil) do |language_processor|
        language_processor.run!
        sleep(0.1)
      end

      assert_equal 0, queue.size
    end

    def test_works_with_unhandled_test_run
      stub_platform_connection!

      uuid = "023949s9dads"
      submission = Submission.new(uuid, :ruby, :bob)
      queue = Queue.new
      queue.push(submission)
      queue.expects(:push).with(submission)

      monitor = mock
      monitor.expects(:record!).with(uuid, 405)

      test_runner = stub_test_runner!
      test_runner.expects(:test!).returns([false, 405])

      with_language_processor(:ruby, queue, monitor, nil) do |language_processor|
        language_processor.run!
        sleep(0.1)
      end
    end
  end
end
