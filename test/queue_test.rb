require 'test_helper'

module Orchestrator
  class QuqueTest < Minitest::Test
    def test_enqueing_and_retrieving
      ruby_two_fer_1 = Submission.new(:ruby, :two_fer, 1)
      ruby_two_fer_2 = Submission.new(:ruby, :two_fer, 2)
      ruby_two_fer_3 = Submission.new(:ruby, :two_fer, 3)
      ruby_two_fer_4 = Submission.new(:ruby, :two_fer, 4)
      javascript_two_fer_1 = Submission.new(:javascript, :two_fer, 1)

      queue = Queue.new
      queue.push(ruby_two_fer_1)
      queue.push(ruby_two_fer_4)
      queue.push(javascript_two_fer_1)
      queue.push(ruby_two_fer_2)
      queue.push(ruby_two_fer_3)

      assert_equal ruby_two_fer_1, queue.shift(language: :ruby)
      assert_equal ruby_two_fer_4, queue.shift(language: :ruby)
      assert_equal ruby_two_fer_2, queue.shift(language: :ruby)
      assert_equal javascript_two_fer_1, queue.shift(language: :javascript)
      assert_equal ruby_two_fer_3, queue.shift(language: :ruby)
    end
  end
end
