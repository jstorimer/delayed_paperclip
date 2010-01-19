module Delayed
  module Paperclip
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      # +process_in_background+ gives the class it is called on an attribute that maps to a file. This
      # is typically a file stored somewhere on the filesystem and has been uploaded by a user. 
      # The attribute returns a Paperclip::Attachment object which handles the management of
      # that file. The intent is to make the attachment as much like a normal attribute. The 
      # thumbnails will be created when the new file is assigned, but they will *not* be saved 
      # until +save+ is called on the record. Likewise, if the attribute is set to +nil+ is 
      # called on it, the attachment will *not* be deleted until +save+ is called. See the 
      # Paperclip::Attachment documentation for more specifics. There are a number of options 
      # you can set to change the behavior of a Paperclip attachment:
      # * +url+: The full URL of where the attachment is publically accessible. This can just
      #   as easily point to a directory served directly through Apache as it can to an action
      #   that can control permissions. You can specify the full domain and path, but usually
      #   just an absolute path is sufficient. The leading slash *must* be included manually for 
      #   absolute paths. The default value is 
      #   "/system/:attachment/:id/:style/:filename". See
      #   Paperclip::Attachment#interpolate for more information on variable interpolaton.
      #     :url => "/:class/:attachment/:id/:style_:filename"
      #     :url => "http://some.other.host/stuff/:class/:id_:extension"
      # * +default_url+: The URL that will be returned if there is no attachment assigned. 
      #   This field is interpolated just as the url is. The default value is 
      #   "/:attachment/:style/missing.png"
      #     has_attached_file :avatar, :default_url => "/images/default_:style_avatar.png"
      #     User.new.avatar_url(:small) # => "/images/default_small_avatar.png"

      def process_in_background(name)
        include InstanceMethods
        
        define_method "#{name}_changed?" do
          attachment_changed?(name)
        end
      end
    end
    
    module InstanceMethods
      PAPERCLIP_ATTRIBUTES = ['_file_size', '_file_name', '_content_type', '_updated_at']
      
      def attachment_changed?(name)
        PAPERCLIP_ATTRIBUTES.each do |attribute|
          return true if self.send("#{name}#{attribute}_changed?")
        end
        
        false
      end
    end
  end
end