$stdout.sync = true
$stderr.sync = true

require "sinatra/base"
require "sinatra/json"

class SubmissionsReceiverApp < Sinatra::Base
  get '/status' do
    json Orchestrator.application.status
  end

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

  post '/languages/:language_slug' do
    Orchestrator.application.add_language(
      params[:language_slug],
      params[:settings]
    )

    json received: :ok
  end

  patch '/languages/:language_slug/settings' do
    Orchestrator.application.update_language_settings(
      params[:language_slug],
      params[:settings]
    )

    json received: :ok
  end

  patch '/languages/:language_slug/scale/:count' do
    Orchestrator.application.scale_processors(
      language: params[:language_slug],
      count: params[:count].to_i
    )

    json received: :ok
  end

  post '/languages/:language_slug/versions' do
    Orchestrator.application.build_version(
      language: params[:language_slug],
      version_slug: params[:version][:slug],
    )

    json received: :ok
  end

  patch '/languages/:language_slug/versions/deploy' do
    p params[:version_slugs]
    Orchestrator.application.deploy_versions(
      language: params[:language_slug],
      version_slugs: params[:version_slugs],
    )

    json received: :ok
  end
end
