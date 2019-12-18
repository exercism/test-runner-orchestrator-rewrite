$stdout.sync = true
$stderr.sync = true

require "sinatra/base"
require "sinatra/json"

class SubmissionsReceiverApp < Sinatra::Base
  post '/submissions' do
    submission_uuid = params[:submission_uuid]
    Logger.log_submission(submission_uuid, "Queuing")

    Orchestrator.application.enqueue_submission(
      submission_uuid,
      params[:language_slug],
      params[:exercise_slug],
    )

    json received: :ok
  end

  patch '/languages/:language_slug/settings' do
    Orchestrator.application.update_language_settings(
      params[:language_slug],
      params[:settings]
    )
  end

  patch '/languages/:language_slug/scale/:count' do
    Orchestrator.application.scale_processors(
      language: params[:language_slug],
      count: params[:count].to_i
    )
  end

  get '/status' do
    json Orchestrator.application.status
  end
end
