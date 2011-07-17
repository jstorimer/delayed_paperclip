module DelayedPaperclip
  module Jobs
    module Base

      def self.process_job(instance_klass, instance_id, attachment_name)
        instance_klass.constantize.find(instance_id)
        .send(attachment_name)
        .process_delayed!
      end

    end
  end
end