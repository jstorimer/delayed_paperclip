module DelayedPaperclip
  module Attachment

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :attr_accessor, :job_is_processing
      base.alias_method_chain :post_processing, :delay
      base.alias_method_chain :save, :prepare_enqueueing
      base.alias_method_chain :url, :processed
      base.alias_method_chain :post_process_styles, :processing
    end

    module InstanceMethods

      def post_processing_with_delay
        !delay_processing?
      end

      def delay_processing?
        !!@instance.class.attachment_definitions[@name][:delayed]
      end

      def processing?
        @instance.send(:"#{@name}_processing?")
      end

      def process_delayed!
        self.job_is_processing = true
        reprocess!
        self.job_is_processing = false
      end

      def post_process_styles_with_processing(*args)
        post_process_styles_without_processing(*args)
        instance.update_attribute("#{name}_processing", false) if instance.respond_to?(:"#{name}_processing?")
      end

      def save_with_prepare_enqueueing
        was_dirty = @dirty
        save_without_prepare_enqueueing.tap do
          if delay_processing? && was_dirty
            instance.prepare_enqueueing_for name
          end
        end
      end

      def url_with_processed style = default_style, include_updated_timestamp = @use_timestamp
        return url_without_processed style, include_updated_timestamp if !@instance.class.attachment_definitions[@name][:delayed].try(:[], :url_with_processing) || job_is_processing

        if !@instance.respond_to?(:"#{name}_processing?")
          url_without_processed style, include_updated_timestamp
        else
          if !processing?
            url_without_processed style, include_updated_timestamp
          else
            if dirty?
              url_without_processed style, include_updated_timestamp
            else
              interpolate(@default_url, style)
            end
          end
        end
      end

    end
  end
end
