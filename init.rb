#
# Add a :processing flag to our model
#
 
class AddProcessingToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :processing, :boolean
  end
 
  def self.down
    remove_column :images, :processing
  end
end
 
 
# 
# In our model:
#
 
class Image
 
  # define our paperclip attachment
  has_attached_file :source ...
    
  ...
  
  # cancel post-processing now, and set flag...
  before_source_post_process do |image|
    if image.source_changed?
      image.processing = true
      false # halts processing
    end
  end
 
  # ...and perform after save in background
  after_save do |image| 
    if image.source_changed?
      Delayed::Job.enqueue ImageJob.new(image.id)
    end
  end
 
  # generate styles (downloads original first)
  def regenerate_styles!
    self.source.reprocess! 
    self.processing = false   
    self.save(false)
  end
 
  # detect if our source file has changed
  def source_changed?
    self.source_file_size_changed? || 
    self.source_file_name_changed? ||
    self.source_content_type_changed? || 
    self.source_updated_at_changed?
  end
  
  ...
  
end
 
#
# Job wrapper (invoked by DelayedJob):
#
 
class ImageJob < Struct.new(:image_id)
  def perform
    Image.find(self.image_id).regenerate_styles!
  end
end

