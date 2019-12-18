module Orchestrator
  class SPIClient

    def self.post_test_run(submission_uuid, status_code, status_message, results)
      url = "#{spi_adddress}/submissions/#{submission_uuid}/test_runs"
      RestClient.post(url, {
        ops_status: status_code,
        ops_message: status_message,
        results: results
      })
    end

    private

    def self.spi_adddress
      @spi_adddress ||= secrets['spi_address']
    end

    def self.secrets
      @secrets ||= YAML::load(ERB.new(File.read(File.dirname(__FILE__) + "/../../config/secrets.yml")).result)[Orchestrator.env]
    end
  end

end

