class DelayedPaperclipJob < Struct.new(:instance_id, :instance_klass, :attachment_name)
  def perform
    instance = instance_klass.constantize.find(instance_id)

    instance.send(attachment_name).reprocess!
    
    if instance.respond_to?(:processing)
      instance.processing = false 
      instance.save
    end
  end
end