$stdout.sync = true
$stderr.sync = true

require "sinatra/base"
require "sinatra/json"
require "orchestrator"


ORCHESTRATOR = Orchestrator::Application.start!

class SubmissionsReceiverApp < Sinatra::Base
  def initialize
    super
    @orchestrator = ORCHESTRATOR
  end

  private
  attr_reader :orchestrator

  post '/submissions' do
    submission_uuid = params[:submission_uuid]
    Logger.log_submission(submission_uuid, "Queuing")

    orchestrator.enqueue_submission(
      submission_uuid,
      params[:language_slug],
      params[:exercise_slug],
    )

    json received: :ok
  end

  patch '/languages/:language/settings' do
    orchestrator.update_language_settings(
      language,
      params[:settings]
    )
  end

  #patch '/languages/:language/scale' do
  #  orchestrator.update_language(
  #    language,
  #    params[:settings]
  #  )
  #end
end
