source "http://rubygems.org"

gemspec

if ENV['LOCAL_PAPERCLIP']
  gem "paperclip", path: '../paperclip'
else
  gem "paperclip", git: 'https://github.com/insales/paperclip'
end

gem "delayed_job", '>= 4.1.10', require: false
gem 'delayed_job_active_record', require: false
gem "resque", require: false
gem "sidekiq"
gem 'redis', '~> 4.5.1' # чтобы 4.6+ не ругался про pipelined в resque

gem 'rails', '~> 6.1.5' # default one for convinience, others are tested via appraisals
