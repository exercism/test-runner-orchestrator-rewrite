class OrchestratorError < RuntimeError
end

class TestRunError < OrchestratorError
  attr_reader :test_run

  def initialize(test_run)
    @test_run = test_run
  end
end
