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

    def enqueue_submission(language_slug, exercise_slug, submission_uuid)
      submission = Submission.new(language_slug, exercise_slug, submission_uuid)
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
