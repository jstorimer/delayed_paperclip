require 'delayed_paperclip/jobs'
require 'delayed_paperclip/attachment'
require 'delayed_paperclip/railtie' if defined?(Rails)

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
      return DelayedPaperclip::Jobs::Sidekiq    if defined? ::Sidekiq
    end

    def processor
      options[:background_job_class]
    end

    def enqueue(instance_klass, instance_id, attachment_name, priority)
      processor.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name, priority)
    end

    def process_job(instance_klass, instance_id, attachment_name)
      instance = instance_klass.constantize.find_by_id(instance_id)
      return unless instance
      instance.send(attachment_name).process_delayed!
    end
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
    extend ActiveSupport::Concern

    module ClassMethods
      def create_immediately_processing(attributes = nil)
        new.tap { |object|
          object.each_attachment do |name, attachment|
            attachment.post_processing = true
          end
          object.attributes = attributes if attributes
        }.tap(&:save)
      end
    end

    # setting each inididual NAME_processing to true, skipping the ActiveModel dirty setter
    # Then immediately push the state to the database
    def mark_enqueue_delayed_processing
      return unless defined?(@_enqued_for_processing_with_processing)
      return if @_enqued_for_processing_with_processing.blank? # catches nil and empy arrays

      updates = @_enqued_for_processing_with_processing.collect{|n| "#{n}_processing = :true" }.join(", ")
      updates = ActiveRecord::Base.send(:sanitize_sql_array, [updates, {:true => true}])
      self.class.where(id: id).update_all(updates)
    end

    # First mark processing
    # then create
    def enqueue_delayed_processing
      mark_enqueue_delayed_processing
      @_enqued_for_processing ||= []
      @_enqued_for_processing.each do |name|
        enqueue_post_processing_for(name)
      end
      @_enqued_for_processing_with_processing = []
      @_enqued_for_processing.clear
    end

    def enqueue_post_processing_for(name)
      # как это вообще работало? ведь нет метода self.priority
      priority = nil
      priority = self.priority if respond_to?(:priority)
      DelayedPaperclip.enqueue(self.class.name, read_attribute(:id), name.to_sym, priority)
    end

    def prepare_enqueueing_for(name)
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
