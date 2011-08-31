require 'test_helper'
require 'base_delayed_paperclip_test'
require 'resque'

class ResquePaperclipTest < Test::Unit::TestCase
  include BaseDelayedPaperclipTest

  def setup
    super
    # Make sure that we just test Resque in here
    DelayedPaperclip.options[:background_job_class] = DelayedPaperclip::Jobs::Resque
    Resque.remove_queue(:paperclip)
  end

  def process_jobs
    worker = Resque::Worker.new(:paperclip)
    worker.process
  end

  def jobs_count
    Resque.size(:paperclip)
  end

  def test_perform_job
    dummy = Dummy.new(:image => File.open("#{RAILS_ROOT}/test/fixtures/12k.png"))
    dummy.image = File.open("#{RAILS_ROOT}/test/fixtures/12k.png")
    Paperclip::Attachment.any_instance.expects(:reprocess!)
    dummy.save!
    DelayedPaperclip::Jobs::Resque.perform(dummy.class.name, dummy.id, :image)
  end

end
