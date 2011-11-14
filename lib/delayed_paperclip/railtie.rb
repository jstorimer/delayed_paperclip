require 'paperclip'
require 'delayed_paperclip'

module DelayedPaperclip
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'delayed_paperclip.insert_into_active_record' do
        ActiveSupport.on_load :active_record do
          DelayedPaperclip::Railtie.insert
        end
      end
    end
  end

  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, DelayedPaperclip::Glue)
      Paperclip::Attachment.send(:include, DelayedPaperclip::Attachment)
    end
  end
end
