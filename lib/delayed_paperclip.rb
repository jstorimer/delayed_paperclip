require 'delayed/paperclip'
require 'delayed/paperclip_job'

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, Delayed::Paperclip)
end