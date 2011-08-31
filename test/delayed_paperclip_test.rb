require 'test_helper'
require 'base_delayed_paperclip_test'
require 'delayed_job'

Delayed::Worker.backend = :active_record

class DelayedPaperclipTest < Test::Unit::TestCase
  include BaseDelayedPaperclipTest

  def setup
    super
    DelayedPaperclip.options[:background_job_class] = DelayedPaperclip::Jobs::DelayedJob
    build_delayed_jobs
  end

  def process_jobs
    Delayed::Worker.new.work_off
  end

  def jobs_count
    Delayed::Job.count
  end

  def test_perform_job
    @dummy.image = File.open("#{RAILS_ROOT}/test/fixtures/12k.png")
    Paperclip::Attachment.any_instance.expects(:reprocess!)

    @dummy.save!
    Delayed::Job.last.payload_object.perform
  end

end
