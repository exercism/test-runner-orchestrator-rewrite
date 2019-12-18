$stdout.sync = true
$stderr.sync = true

require "sinatra/base"
require "sinatra/json"
require "orchestrator"


class SubmissionsReceiverApp < Sinatra::Base
  def initialize
    super
    @orchestrator = Orchestrator::Application.start!
  end

  private
  attr_reader :orchestrator

  post '/submissions' do
    submission_uuid = params[:submission_uuid]
    puts "Queuing #{submission_uuid.split("-").last}: #{submission_uuid}"

    orchestrator.enqueue_submission(
      params[:track_slug],
      params[:exercise_slug],
      submission_uuid
    )

    json received: :ok
  end
end
