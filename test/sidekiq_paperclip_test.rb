require 'test_helper'
require 'base_delayed_paperclip_test'
require 'sidekiq'
require 'sidekiq/testing'

class SidekiqPaperclipTest < DelayedPaperclip::TestCase
  include BaseDelayedPaperclipTest

  def setup
    super
    DelayedPaperclip.options[:background_job_class] = DelayedPaperclip::Jobs::Sidekiq
    Sidekiq::Worker.clear_all
    Sidekiq.strict_args!
  end

  def process_jobs
    Sidekiq::Worker.drain_all
  end

  def jobs_count
    DelayedPaperclip::Jobs::Sidekiq.jobs.size
  end

  def test_perform_job
    dummy = Dummy.new(:image => File.open("#{RAILS_ROOT}/test/fixtures/12k.png"))
    dummy.image = File.open("#{RAILS_ROOT}/test/fixtures/12k.png")
    Paperclip::Attachment.any_instance.expects(:reprocess!)
    dummy.save!
    assert_equal 1, jobs_count
    process_jobs
  end
end
