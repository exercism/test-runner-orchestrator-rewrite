class Logger
  def self.log(*args)
    return if Orchestrator.env == "test"

    STDERR.puts(*args)
  end

  def self.log_submission(submission, msg)
    submission_uuid = submission.is_a?(String) ? submission : submission.uuid
    log("[#{submission_uuid}] #{msg}")
  end
end
