require 'test_helper'

module Orchestrator
  class QueueTest < Minitest::Test
    def test_enqueing_and_retrieving
      ruby_two_fer_1 = Submission.new(:ruby, :two_fer, 1)
      ruby_two_fer_2 = Submission.new(:ruby, :two_fer, 2)
      ruby_two_fer_3 = Submission.new(:ruby, :two_fer, 3)
      ruby_two_fer_4 = Submission.new(:ruby, :two_fer, 4)

      queue = Queue.new
      queue.push(ruby_two_fer_1)
      queue.push(ruby_two_fer_4)
      queue.push(ruby_two_fer_2)
      queue.push(ruby_two_fer_3)

      assert_equal 4, queue.size

      assert_equal ruby_two_fer_1, queue.shift
      assert_equal ruby_two_fer_4, queue.shift
      assert_equal ruby_two_fer_2, queue.shift
      assert_equal ruby_two_fer_3, queue.shift

      assert_equal 0, queue.size
    end

    def test_retrieving_nothing
      queue = Queue.new
      assert_nil queue.shift
    end
  end
end
