module DelayedPaperclip
  module Attachment
    attr_accessor :job_is_processing

    def post_processing
      !delay_processing?
    end

    def post_processing=(value)
      @post_processing_with_delay = value
    end

    def delayed_options
      instance.class.attachment_definitions[name][:delayed]
    end

    def delay_processing?
      if !defined?(@post_processing_with_delay) || @post_processing_with_delay.nil?
        !!delayed_options
      else
        !@post_processing_with_delay
      end
    end

    def processing?
      instance.send(:"#{name}_processing?")
    end

    def process_delayed!
      self.job_is_processing = true
      reprocess!
      self.job_is_processing = false
    end

    def post_process_styles(*)
      super

      # update_column is available in rails 3.1 instead we can do this to update the attribute without callbacks

      #instance.update_column("#{name}_processing", false) if instance.respond_to?(:"#{name}_processing?")
      if instance.respond_to?(:"#{name}_processing?")
        instance.send("#{name}_processing=", false)
        instance.class.where(instance.class.primary_key => instance.id).update_all("#{name}_processing" => false)
      end
    end

    def save
      was_dirty = dirty?
      super.tap do
        instance.prepare_enqueueing_for(name) if delay_processing? && was_dirty
      end
    end

    def most_appropriate_url
      if original_filename.nil? || delayed_default_url?
        default_url
      else
        options.url
      end
    end

    def delayed_default_url?
      !(job_is_processing || dirty? || !delayed_options.try(:[], :url_with_processing) ||
        !(instance.respond_to?(:"#{name}_processing?") && processing?))
    end
  end
end
