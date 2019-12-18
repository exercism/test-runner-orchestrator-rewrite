# This should be treated as an internal class
# Methods should not be accessed directly but
# instead through the Application class, which
# guarantees thread safety.
module Orchestrator
  class Language
    attr_reader :timeout_ms, :container_version

    def initialize(settings_hash)
      @queue = Queue.new
      @processors_mvar = Concurrent::MVar.new([])
      @settings = LanguageSettings.new(settings_hash)
    end

    def update_settings(data)
      settings.update(data)
    end

    def scale_processors(new_count)
      processors_mvar.borrow do |processors|
        # Let's get this cached for sanity's sake
        current_count = processors.size

        return if current_count == new_count

        if new_count > current_count
          (new_count - current_count).times do
            processors.push(LanguageProcessor.run!(queue, settings))
          end
        else
          processors[0, (current_count - new_count)].each do |processor|
            processor.exit!
            processors.delete(processor)
          end
        end
      end
    end

    def enqueue_submission(submission)
      queue.push(submission)
    end

    def queue_size
      queue.size
    end

    def num_processors
      processors_mvar.borrow(&:size)
    end

    private
    attr_reader :queue, :processors_mvar, :settings
  end
end
