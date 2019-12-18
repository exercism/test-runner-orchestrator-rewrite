class OrchestratorError < RuntimeError
end

class NoWorkersAvailableError < OrchestratorError
end
