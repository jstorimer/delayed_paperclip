require 'delayed/paperclip'

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, Delayed::Paperclip)
end