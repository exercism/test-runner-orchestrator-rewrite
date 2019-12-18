require 'test_helper'

module Orchestrator
  class LanguageProcessorTest < Minitest::Test
    def test_runs_and_exits
      stub_test_runner!

      queue = mock

      # TODO - Add a range of 9-11 here
      # This should be 1 / CHECK_FREQUENCY_MS.to_s
      queue.expects(:shift).at_least(9)

      language_processor = LanguageProcessor.new(queue, nil)

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
      submission = Submission.new("023949s9dads", :ruby, :bob)
      queue = Queue.new
      queue.push(submission)

      test_runner = stub_test_runner!
      test_runner.expects(:test_submission).with(submission).returns(true)

      with_language_processor(:ruby, queue, nil) do |language_processor|
        language_processor.run!
        sleep(0.1)
      end

      assert_equal 0, queue.size
    end

    def test_iterates_and_requeues_if_run_fails
      stub_spi_client!
      submission = Submission.new("023949s9dads", :ruby, :bob)
      submission.expects(:increment_errors!)
      submission.expects(:errored_too_many_times?).returns(false)

      queue = Queue.new
      queue.push(submission)
      queue.expects(:push).with(submission)

      test_run = mock(no_workers_available?: false, status_code: nil)
      test_runner = stub_test_runner!
      test_runner.expects(:test_submission).with(submission).raises(TestRunError.new(test_run))

      with_language_processor(:ruby, queue, nil) do |language_processor|
        language_processor.run!
        sleep(0.1)
      end
    end

    def test_posts_to_spi_if_too_many_errors
      stub_spi_client!
      submission = Submission.new("023949s9dads", :ruby, :bob)
      submission.expects(:increment_errors!)
      submission.expects(:errored_too_many_times?).returns(true)

      queue = Queue.new
      queue.push(submission)
      queue.expects(:push).never

      test_run = mock(no_workers_available?: false, status_code: nil)
      test_run.expects(:post_to_spi!)
      test_runner = stub_test_runner!
      test_runner.expects(:test_submission).with(submission).raises(TestRunError.new(test_run))

      with_language_processor(:ruby, queue, nil) do |language_processor|
        language_processor.run!
        sleep(0.1)
      end

    end


    def test_sleeps_if_queue_is_empty
      stub_test_runner!

      queue = mock
      queue.expects(:shift).returns(nil).at_least_once

      with_language_processor(:ruby, queue, mock) do |language_processor|
        language_processor.expects(:sleep).with(0.1).at_least_once
        language_processor.run!
        sleep(0.1) # Sleep to let it happen
      end
    end

    def test_no_worker_loop
      stub_spi_client!

      submission = Submission.new("foobar-1", :ruby, :bob)

      queue = mock
      queue.expects(:push).with(submission)
      test_run = mock
      test_run.stubs(no_workers_available?: true, status_code: nil)
      test_runner = stub_test_runner!
      test_runner.expects(:test_submission).times(40).with(submission).raises(TestRunError.new(test_run))

      with_language_processor(nil, queue) do |language_processor|
        language_processor.expects(:sleep).times(39).with(0.05)
        language_processor.send(:test_submission!, submission)
      end
    end

    def test_bad_exception_loop
      stub_spi_client!

      submission = Submission.new("foobar", :ruby, :bob)

      queue = mock
      queue.expects(:push).with(submission)

      test_runner = stub_test_runner!
      test_runner.expects(:test_submission).twice.with(submission).raises(RuntimeError)

      with_language_processor(nil, queue) do |language_processor|
        language_processor.send(:test_submission!, submission)
      end
    end
  end
end
