require 'test_helper'

module Orchestrator
  class LanguageMonitorTest < Minitest::Test
    def test_records_correctly
      monitor = LanguageMonitor.new
      assert_equal [], monitor.recent_statuses

      statuses = [200,300,402,502,201,304,230,300]
      statuses.each do |status|
        monitor.record!(SecureRandom.uuid, status)
      end

      assert_equal statuses, monitor.recent_statuses
    end

    def test_prunes
      monitor = LanguageMonitor.new

      Timecop.freeze(Time.new(2019,01,01,12,00)) do
        monitor.record!(SecureRandom.uuid, 200)
        assert_equal [200], monitor.recent_statuses
      end

      Timecop.freeze(Time.new(2019,01,01,12,11)) do
        monitor.record!(SecureRandom.uuid, 500)
        assert_equal [500], monitor.send(:results).map{|r|r[2]}
      end
    end

    def test_filters_only_last_10_mins
      monitor = LanguageMonitor.new

      Timecop.freeze(Time.new(2019,01,01,12,00)) do
        monitor.record!(SecureRandom.uuid, 200)
        assert_equal [200], monitor.recent_statuses
      end

      Timecop.freeze(Time.new(2019,01,01,12,8)) do
        monitor.record!(SecureRandom.uuid, 300)
        assert_equal [200,300], monitor.recent_statuses
      end

      Timecop.freeze(Time.new(2019,01,01,12,9)) do
        monitor.record!(SecureRandom.uuid, 400)
        assert_equal [200,300,400], monitor.recent_statuses
      end

      Timecop.freeze(Time.new(2019,01,01,12,11)) do
        monitor.record!(SecureRandom.uuid, 500)
        assert_equal [300,400,500], monitor.recent_statuses
      end
    end
  end
end

