require 'test/test_helper'

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
  
  def test_halt_processing_if_source_changed_and_processing_attribute_defined
    reset_table("dummies") do |d|
      d.string :image_file_name
      d.integer :image_file_size
      d.boolean :processing
    end
    @dummy_class = reset_class "Dummy"
    @dummy_class.has_attached_file :image
    @dummy_class.process_in_background :image
    @dummy = Dummy.new(:image => File.read("#{RAILS_ROOT}/test/fixtures/12k.png"))
    
    @dummy.stubs(:image_changed?).returns(true)
    assert !@dummy.halt_processing_for_image
    assert @dummy.processing
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
    DelayedPaperclipJob.new(@dummy.id, @dummy.class.name, :image).perform
  end
  
  def test_perform_job_with_processing_attribute
    reset_table("dummies") do |d|
      d.string :image_file_name
      d.integer :image_file_size
      d.boolean :processing
    end
    @dummy_class = reset_class "Dummy"
    @dummy_class.has_attached_file :image
    @dummy_class.process_in_background :image
    
    @dummy = Dummy.new(:image => File.open("#{RAILS_ROOT}/test/fixtures/12k.png"))

    Paperclip::Attachment.any_instance.expects(:reprocess!)
    
    @dummy.processing = true
    @dummy.save!
    DelayedPaperclipJob.new(@dummy.id, @dummy.class.name, :image).perform
    
    assert !@dummy.reload.processing
  end
  
  private 
  def reset_dummy
    reset_table("dummies") do |d|
      d.string :image_file_name
      d.integer :image_file_size
    end
    @dummy_class = reset_class "Dummy"
    @dummy_class.has_attached_file :image
    @dummy_class.process_in_background :image
    
    @dummy = Dummy.new(:image => File.open("#{RAILS_ROOT}/test/fixtures/12k.png"))
  end
end
