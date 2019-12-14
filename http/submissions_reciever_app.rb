$stdout.sync = true
$stderr.sync = true

require "sinatra/base"
require "sinatra/json"
require "orchestrator"

application = Orchestrator::Application.start!

class SubmissionsReceiverApp < Sinatra::Base
  post '/submissions' do
    submission = Submission.new(
      params[:track_slug], 
      params[:exercise_slug],  
      params[:submission_uuid]
    )
    puts "Queuing #{submission_uuid.split("-").last}: #{submission_uuid}"
    application.enqueue(submission)

    json received: :ok
  end
end
