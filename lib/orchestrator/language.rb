# This should be treated as an internal class
# Methods should not be accessed directly but
# instead through the Application class, which
# guarantees thread safety.
module Orchestrator
  class Language
    attr_reader :settings

    def initialize(slug, settings_hash)
      @slug = slug
      @queue = Queue.new
      @processors_mvar = Concurrent::MVar.new([])
      @settings = LanguageSettings.new(settings_hash)
      @monitor = LanguageMonitor.new
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
            processors.push(LanguageProcessor.run!(queue, monitor, settings))
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

    def build_version(version_slug)
      PlatformConnection.new.build_version(slug, version_slug)
    end

    def deploy_version(version_slug)
      PlatformConnection.new.deploy_version(slug, version_slug)
    end

    def queue_size
      queue.size
    end

    def num_processors
      processors_mvar.borrow(&:size)
    end

    private
    attr_reader :slug, :queue, :monitor, :processors_mvar, :mangagement_platform_connection
  end
end
