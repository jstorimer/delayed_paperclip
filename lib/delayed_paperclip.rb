require 'paperclip'
require 'resque'
require 'delayed/paperclip'
require 'delayed/resque_paperclip_job'

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, Delayed::Paperclip)
end