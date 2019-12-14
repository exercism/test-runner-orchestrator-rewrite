require 'erb'
require "mandate"
require 'rbczmq'
require 'json'
require 'yaml'
require 'securerandom'
require 'concurrent-ruby'
require 'rest-client'

require "orchestrator/application"
require "orchestrator/language_processor"
require "orchestrator/platform_connection"
require "orchestrator/queue"
require "orchestrator/submission"
require "orchestrator/test_runner"

module Orchestrator
  def self.application
  end
end
