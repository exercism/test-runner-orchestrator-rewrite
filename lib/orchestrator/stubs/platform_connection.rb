# This is a stub for use in development
# to avoid the need for zeromq connections
#
# If returns:
#   200 for :ruby (Success)
#   400 for :javascript (Hard failure)
#   503 for :csharp (Busy workers)
#   512 for :haskell (Other error)
#
# and always returns the same results hash.
module Orchestrator
  class PlatformConnection

    def initialize(address: nil)
    end

    def open_socket
    end

    def run_tests(track_slug, exercise_slug, s3_uri, container_slug, timeout_ms)
      status_code = case track_slug
        when :ruby
          200
        when :javascript
          400
        when :csharp
          503
        when :haskell
          512
        end

      {
        "status" => { "status_code" => status_code },
        "response" => { "something" => "here" }
      }
    end
  end
end
