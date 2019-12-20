module Orchestrator
  class Application
    def self.start!
      new.tap(&:start!)
    end

    def initialize
      @languages = Concurrent::MVar.new(Hash.new)
    end

    def start!
      return if Orchestrator.env == 'test'

      SPIClient.fetch_languages.each do |slug, settings|
        slug = slug.to_sym
        add_language(slug, settings)
      end

      SPIClient.fetch_submissions_to_test.each do |submission|
        enqueue_submission(
          submission["uuid"],
          submission["language_slug"],
          submission["exercise_slug"]
        )
      end

      true
    end

    def add_language(slug, settings)
      language = Language.new(slug, settings)
      language.scale_processors(settings['num_processors'].to_i)

      borrow_languages do |languages|
        languages[slug.to_sym] = language
      end

      true
    end

    def update_language_settings(slug, settings)
      borrow_language(slug.to_sym) do |language|
        language.update_settings(settings)
      end

      true
    end

    def enqueue_submission(uuid, language_slug, exercise_slug)
      language_slug = language_slug.to_sym
      exercise_slug = exercise_slug.to_sym

      submission = Submission.new(uuid, language_slug, exercise_slug)
      borrow_language(submission.language) do |lang|
        lang.enqueue_submission(submission)
      end

      true
    end

    def scale_processors(language:, count:)
      borrow_language(language.to_sym) do |lang|
        lang.scale_processors(count)
      end

      true
    end

    def queue_size(language: )
      borrow_language(language.to_sym) do |lang|
        lang.queue_size
      end
    end

    def num_processors(language: )
      borrow_language(language.to_sym) do |lang|
        lang.num_processors
      end
    end

    def status
      borrow_languages do |langs|
        langs.each_with_object({}) do |(slug, lang), output|
          output[slug] = {
            num_processors: lang.num_processors,
            queue_size: lang.queue_size,
            settings: {
              timeout_ms: lang.settings.timeout_ms,
              version_slug: lang.settings.version_slug
            }
          }
        end
      end
    end

    def build_version(language:, version_slug:)
      PlatformConnection.new.build_version(language, version_slug)
    end

    def deploy_version(language:, version_slug:)
      PlatformConnection.new.deploy_version(language, version_slug)
    end

    private
    attr_reader :languages

    def borrow_languages
      languages.borrow do |langs|
        yield(langs)
      end
    end

    def borrow_language(lang)
      borrow_languages do |langs|
        yield(langs[lang])
      end
    end
  end
end
