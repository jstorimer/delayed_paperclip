require 'sidekiq/worker'

module DelayedPaperclip
  module Jobs
    class Sidekiq
      include ::Sidekiq::Worker
      def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name, priority)
        # to set priority - use `DelayedPaperclip::Jobs::Sidekiq.sidekiq_options queue: :image_processing`
        ::Sidekiq::Client.enqueue(
          ::DelayedPaperclip::Jobs::Sidekiq,
          instance_klass.to_s, instance_id, attachment_name.to_s
        )
      end

      def perform(instance_klass, instance_id, attachment_name)
        DelayedPaperclip.process_job(instance_klass, instance_id, attachment_name.to_sym)
      end
    end
  end
end
