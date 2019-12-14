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
require "orchestrator/language_processor"
require "orchestrator/language_settings"
require "orchestrator/platform_connection"
require "orchestrator/queue"
require "orchestrator/submission"
require "orchestrator/test_runner"

module Orchestrator
  def self.env
    @env ||= (ENV["ENV"] || "development")
  end
end
