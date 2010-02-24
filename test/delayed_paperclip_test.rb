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
    @dummy.stubs(:image_content_type_changed?).returns(false)
    @dummy.stubs(:image_updated_at_changed?).returns(false)

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
    @dummy.stubs(:image_changed?).returns(true)
    Paperclip::Attachment.any_instance.expects(:reprocess!)

    @dummy.save!
    Delayed::Job.last.payload_object.perform
  end

  def test_after_callback_is_functional
    @dummy_class.send(:define_method, :done_processing) { puts 'done' }
    @dummy_class.after_image_post_process :done_processing
    Dummy.any_instance.expects(:done_processing)

    @dummy.save!
    DelayedPaperclipJob.new(@dummy.class.name, @dummy.id, :image).perform
  end

  def test_processed_methods_added_if_processed_column_does_not_exist
    assert @dummy.respond_to?(:image_processed)
    assert @dummy.respond_to?(:image_processed=)
    assert @dummy.respond_to?(:image_processed!)
    assert @dummy.respond_to?(:image_processing!)
    assert @dummy.image_processed?
  end

  def test_processed_methods_always_return_true
    @dummy.image_processed = false
    assert @dummy.image_processed

    @dummy.image_processing!
    assert @dummy.image_processed
    assert @dummy.image_processed?
  end

  def test_processed_false_when_new_image_added
    reset_dummy(true)

    @dummy = Dummy.new(:image => File.open("#{RAILS_ROOT}/test/fixtures/12k.png"))

    assert  @dummy.image_processed?
    assert  @dummy.save!
    assert !@dummy.image_processed?
  end

  def test_processed_true_when_delayed_jobs_completed
    reset_dummy(true)

    @dummy = Dummy.new(:image => File.open("#{RAILS_ROOT}/test/fixtures/12k.png"))
    @dummy.save!

    Delayed::Job.first.invoke_job

    @dummy.reload
    assert @dummy.image_processed?
  end
end
