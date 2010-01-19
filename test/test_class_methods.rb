module TestClassMethods
  def self.included(base)
    base.send(:extend, ClassMethods)
  end
  
  module ClassMethods
    def has_attached_file(attachment_name)
    end
  end
end