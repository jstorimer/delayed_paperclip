require 'delayed_paperclip/jobs'

module DelayedPaperclip

  class << self

    def options
      @options ||= {
        :background_job_class => detect_background_task,
        :url_with_processing  => true
      }
    end

    def detect_background_task
      return DelayedPaperclip::Jobs::DelayedJob if defined? ::Delayed::Job
      return DelayedPaperclip::Jobs::Resque     if defined? ::Resque
    end

    def processor
      options[:background_job_class]
    end

    def enqueue(instance_klass, instance_id, attachment_name)
      processor.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
    end

    def process_job(instance_klass, instance_id, attachment_name)
      instance_klass.constantize.find(instance_id).
        send(attachment_name).
        process_delayed!
    end

  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def process_in_background(name, options = {})
      include InstanceMethods

      attachment_definitions[name][:delayed] = {}
      {
        :priority => 0,
        :url_with_processing => DelayedPaperclip.options[:url_with_processing]
      }.each do |option, default|
        attachment_definitions[name][:delayed][option] = options.key?(option) ? options[option] : default
      end

      if respond_to?(:after_commit)
        after_commit  :enqueue_delayed_processing
      else
        after_save  :enqueue_delayed_processing
      end
    end
  end

  module InstanceMethods

    # setting each inididual NAME_processing to true, skipping the ActiveModel dirty setter
    # Then immediately push the state to the database
    def mark_enqueue_delayed_processing
      unless @_enqued_for_processing_with_processing.blank? # catches nil and empy arrays
        updates = @_enqued_for_processing_with_processing.collect{|n| "#{n}_processing = :true" }.join(", ")
        updates = ActiveRecord::Base.send(:sanitize_sql_array, [updates, {:true => true}])
        self.class.update_all(updates, "id = #{self.id}")
      end
    end

    # First mark processing
    # then create
    def enqueue_delayed_processing
      mark_enqueue_delayed_processing
      (@_enqued_for_processing || []).each do |name|
        enqueue_post_processing_for(name)
      end
      @_enqued_for_processing_with_processing = []
      @_enqued_for_processing = []
    end

    def enqueue_post_processing_for name
      DelayedPaperclip.enqueue(self.class.name, read_attribute(:id), name.to_sym)
    end

    def attachment_for name
      @_paperclip_attachments ||= {}
      @_paperclip_attachments[name] ||= ::Paperclip::Attachment.new(name, self, self.class.attachment_definitions[name]).tap do |a|
        a.post_processing = false if self.class.attachment_definitions[name][:delayed]
      end
    end

    def prepare_enqueueing_for name
      if self.attributes.has_key? "#{name}_processing"
        write_attribute("#{name}_processing", true)
        @_enqued_for_processing_with_processing ||= []
        @_enqued_for_processing_with_processing << name
      end
      @_enqued_for_processing ||= []
      @_enqued_for_processing << name
    end

  end
end

module Paperclip
  class Attachment
    attr_accessor :job_is_processing

    def save_with_prepare_enqueueing
      was_dirty = @dirty
      save_without_prepare_enqueueing.tap do
        if delay_processing? && was_dirty
          instance.prepare_enqueueing_for name
        end
      end
    end
    alias_method_chain :save, :prepare_enqueueing

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
    alias_method_chain :url, :processed

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
    alias_method_chain :post_process_styles, :processing

  end
end

