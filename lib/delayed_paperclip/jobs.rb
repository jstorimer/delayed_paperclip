module DelayedPaperclip
  module Jobs
    autoload :DelayedJob, 'delayed_paperclip/jobs/delayed_job'
    autoload :Resque, 'delayed_paperclip/jobs/resque'
  end
end
