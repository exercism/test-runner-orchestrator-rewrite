require 'erb'
require "mandate"
require 'rbczmq'
require 'json'
require 'yaml'
require 'securerandom'
require 'concurrent-ruby'
require 'rest-client'

require "ext/string"
require "ext/nilclass"

require "orchestrator/application"
require "orchestrator/exceptions"
require "orchestrator/language"
require "orchestrator/language_settings"
require "orchestrator/language_processor"
require "orchestrator/platform_connection"
require "orchestrator/queue"
require "orchestrator/spi_client"
require "orchestrator/submission"
require "orchestrator/test_run"
require "orchestrator/test_runner"

module Orchestrator
  def self.env
    @env ||= (ENV["ENV"] || "development")
  end
end
