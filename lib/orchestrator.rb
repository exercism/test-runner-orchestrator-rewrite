ENV["APP_ENV"] ||= "development"

require 'concurrent-ruby'
require 'erb'
require 'json'
require "mandate"
require 'rbczmq'
require 'rest-client'
require 'securerandom'
require 'yaml'

require "ext/nil_class"
require "ext/s3"
require "ext/string"

require "orchestrator/application"
require "orchestrator/exceptions"
require "orchestrator/language"
require "orchestrator/language_monitor"
require "orchestrator/language_settings"
require "orchestrator/language_processor"
require "orchestrator/logger"
require "orchestrator/platform_connection"
require "orchestrator/queue"
require "orchestrator/spi_client"
require "orchestrator/submission"
require "orchestrator/test_run"
require "orchestrator/test_runner"

require "orchestrator/http/app"

# Stubbed methods to avoid having to work
# with zmq locally. See files for details.
if ENV["APP_ENV"] == "development"
  require "orchestrator/stubs/platform_connection"
end

module Orchestrator
  def self.env
    @env ||= ENV["APP_ENV"]
  end

  def self.application
    @application ||= Orchestrator::Application.start!
  end
end

# Get a new application on this main thread
# before sinatra or anything else kicks in
Orchestrator.application
