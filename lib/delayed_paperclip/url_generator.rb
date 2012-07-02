module Paperclip
  class UrlGenerator

    def most_appropriate_url
      if @attachment.original_filename.nil? || @attachment.delayed_default_url?
        default_url
      else
        @attachment_options[:url]
      end
    end

  end
end