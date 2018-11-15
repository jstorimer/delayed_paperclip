require 'sidekiq/worker'

module DelayedPaperclip
  module Jobs
    class Sidekiq
      include ::Sidekiq::Worker
      def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name, priority)
        default_queue = get_sidekiq_options['queue']
        q = priority ? "#{default_queue}_#{priority}" : default_queue
        ::Sidekiq::Client.enqueue_to(q, ::DelayedPaperclip::Jobs::Sidekiq, instance_klass, instance_id, attachment_name)
      end

      def perform(instance_klass, instance_id, attachment_name)
        DelayedPaperclip.process_job(instance_klass, instance_id, attachment_name)
      end
    end
  end
end
