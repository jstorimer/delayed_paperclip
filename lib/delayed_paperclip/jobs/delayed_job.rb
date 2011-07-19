module DelayedPaperclip
  module Jobs
    class DelayedJob < Struct.new(:instance_klass, :instance_id, :attachment_name)

      def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
        ::Delayed::Job.enqueue(
          new(instance_klass, instance_id, attachment_name),
          :priority => instance_klass.constantize.attachment_definitions[attachment_name][:delayed_priority].to_i
        )
      end

      def perform
        DelayedPaperclip.process_job(instance_klass, instance_id, attachment_name)
      end
    end
  end
end