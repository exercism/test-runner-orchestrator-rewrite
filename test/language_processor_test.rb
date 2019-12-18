require 'test_helper'

module Orchestrator
  class LanguageProcessorTest < Minitest::Test
    def test_runs_and_exits
      stub_test_runner!

      queue = mock

      # TODO - Add a range of 9-11 here
      # This should be 1 / CHECK_FREQUENCY_MS.to_s
      queue.expects(:shift).with(language: :ruby).at_least(9)

      language_processor = LanguageProcessor.new(:ruby, queue, mock)

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

    def test_runs_a_submission_correctly
      stub_spi_client!
      submission = Submission.new(:ruby, :bob, "023949s9dads")
      queue = Queue.new
      queue.push(submission)

      test_runner = stub_test_runner!
      test_runner.expects(:process_submission).with(submission).returns(true)

      with_language_processor(:ruby, queue, nil) do |language_processor|
        language_processor.run!
        sleep(0.1)
      end

      assert_equal 0, queue.size
    end

    def test_requeues_if_run_fails
      stub_spi_client!
      submission = Submission.new(:ruby, :bob, "023949s9dads")
      queue = Queue.new
      queue.push(submission)
      queue.expects(:push).with(submission)

      test_runner = stub_test_runner!
      test_runner.expects(:process_submission).with(submission).returns(false)

      with_language_processor(:ruby, queue, nil) do |language_processor|
        language_processor.run!
        sleep(0.1)
      end
    end

    def test_sleeps_if_queue_is_empty
      stub_test_runner!

      queue = mock
      queue.expects(:shift).with(language: :ruby).returns(nil).at_least_once

      with_language_processor(:ruby, queue, mock) do |language_processor|
        language_processor.expects(:sleep).with(0.1).at_least_once
        language_processor.run!
        sleep(0.1) # Sleep to let it happen
      end
    end

    def test_no_worker_loop
      stub_spi_client!

      submission = mock

      queue = mock
      queue.stubs(shift: submission)

      test_runner = stub_test_runner!
      test_runner.expects(:process_submission).times(40).with(submission).raises(NoWorkersAvailableError)

      with_language_processor(:ruby, mock, mock) do |language_processor|
        language_processor.expects(:sleep).times(39).with(0.05)
        language_processor.send(:test_submission!, submission)
      end
    end
  end
end
