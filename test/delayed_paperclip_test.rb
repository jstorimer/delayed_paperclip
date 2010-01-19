require 'test/test_helper'

class Dummy < ActiveRecord::Base
  include TestClassMethods
  has_attached_file :image
  
  process_in_background :image
end

class DelayedPaperclipTest < Test::Unit::TestCase
  def setup
    @dummy = Dummy.new
  end
  
  def test_attachment_changed
    assert !@dummy.image_changed?
  end
  
  def test_attachment_changed_when_image_changes
    @dummy.stubs(:image_content_type_changed?).returns(true)

    assert @dummy.image_changed?
  end
end
