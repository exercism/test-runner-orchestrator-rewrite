module Orchestrator
  class Application
    def self.start!
      new.tap(&:start!)
    end

    def initialize
      @languages = Concurrent::MVar.new(Hash.new)
    end

    def start!
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
    end

    def add_language(slug, settings)
      language = Language.new(settings)
      settings['num_processors'].times do
        language.add_processor
      end

      borrow_languages do |languages|
        languages[slug] = language
      end
    end

    def update_language_settings(slug, settings)
      borrow_language(slug) do |language|
        language.update_settings(settings)
      end
    end

    def enqueue_submission(uuid, language_slug, exercise_slug)
      submission = Submission.new(uuid, language_slug, exercise_slug)
      borrow_language(submission.language) do |lang|
        lang.enqueue_submission(submission)
      end
    end

    def add_processor(language: )
      borrow_language(language.to_sym) do |lang|
        lang.add_processor
      end
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
