module Orchestrator
  module S3
    def self.bucket
      @bucket ||= begin
        secrets = YAML::load(
          ERB.new(
            File.read(
              File.dirname(__FILE__) + "/../../config/secrets.yml")
          ).result
        )[Orchestrator.env]
        secrets['aws_submissions_bucket']
      end
    end
  end
end
