module Delayed
  module Paperclip
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def process_in_background(name)
        include InstanceMethods

        define_method "#{name}_changed?" do
          attachment_changed?(name)
        end
        
        define_method "halt_processing_for_#{name}" do
          if self.send("#{name}_changed?")
            false # halts processing
          end
        end
        
        define_method "enqueue_job_for_#{name}" do
          if self.send("#{name}_changed?")
            if delayed_job?
              Delayed::Job.enqueue DelayedPaperclipJob.new(read_attribute(:id), self.class.name, name.to_sym)
            elsif resque?
              Resque.enqueue(ResquePaperclipJob, self.class.name, read_attribute(:id), name.to_sym)
            end
          end
        end
        
        self.send("before_#{name}_post_process", :"halt_processing_for_#{name}")
        after_save :"enqueue_job_for_#{name}"
      end
    end
    
    module InstanceMethods
      PAPERCLIP_ATTRIBUTES = ['_file_size', '_file_name', '_content_type', '_updated_at']
      
      def attachment_changed?(name)
        PAPERCLIP_ATTRIBUTES.each do |attribute|
          full_attribute = "#{name}#{attribute}_changed?".to_sym

          next unless self.respond_to?(full_attribute)
          return true if self.send("#{name}#{attribute}_changed?")
        end
        
        false
      end
      
      def delayed_job?
        defined? Delayed::Job
      end
      
      def resque?
        defined? Resque
      end
    end
  end
end