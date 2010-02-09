require 'test/test_helper'
gem 'delayed_job'
require 'delayed_job'

class DelayedPaperclipTest < Test::Unit::TestCase
  def setup
    build_delayed_jobs
    reset_dummy
  end
  
  def test_attachment_changed
    @dummy.stubs(:image_file_size_changed?).returns(false)
    @dummy.stubs(:image_file_name_changed?).returns(false)
    
    assert !@dummy.image_changed?
  end
  
  def test_attachment_changed_when_image_changes
    @dummy.stubs(:image_file_size_changed?).returns(true)

    assert @dummy.image_changed?
  end
  
  def test_before_post_process
    Dummy.expects(:before_image_post_process)
    @dummy_class.process_in_background :image
  end
  
  def test_halt_processing_if_source_changed
    @dummy.stubs(:image_changed?).returns(true)
    assert !@dummy.halt_processing_for_image
  end
  
  def test_halt_processing_if_source_has_not_changed
    @dummy.stubs(:image_changed?).returns(false)
    assert_not_equal false, @dummy.halt_processing_for_image
  end
  
  def test_after_save
    Dummy.expects(:after_save)
    @dummy_class.process_in_background :image
  end
  
  def test_enqueue_job_if_source_changed
    @dummy.stubs(:image_changed?).returns(true)

    original_job_count = Delayed::Job.count
    @dummy.enqueue_job_for_image

    assert_equal original_job_count + 1, Delayed::Job.count
  end

  def test_perform_job
    Paperclip::Attachment.any_instance.expects(:reprocess!)

    @dummy.save!
    DelayedPaperclipJob.new(@dummy.class.name, @dummy.id, :image).perform
  end

  def test_after_callback_is_functional
    @dummy_class.send(:define_method, :done_processing) { puts 'done' }
    @dummy_class.after_image_post_process :done_processing    
    Dummy.any_instance.expects(:done_processing)

    @dummy.save!
    DelayedPaperclipJob.new(@dummy.class.name, @dummy.id, :image).perform
  end
end
