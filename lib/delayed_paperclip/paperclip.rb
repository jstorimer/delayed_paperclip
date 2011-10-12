module Paperclip
  
  class Attachment
    
    def url(style_name = default_style, use_timestamp = @use_timestamp)
      default_url = @default_url.is_a?(Proc) ? @default_url.call(self) : @default_url
      url = exists?(style_name) ? interpolate(@url, style_name) : interpolate(default_url, style_name)
      use_timestamp && updated_at ? [url, updated_at].compact.join(url.include?("?") ? "&" : "?") : url
    end
    
  end
  
  module Interpolations

    def size(attachment, style_name)
      return attachment.styles[style_name].geometry.to_s.gsub(/[^0-9x]/, '\\1').gsub(/^[x]+|[x]+$/, '')
    end
    
  end
  
end