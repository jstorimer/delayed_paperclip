class DelayedPaperclipJob < Struct.new(:instance_klass, :instance_id, :attachment_name)
  def perform
    instance = instance_klass.constantize.find(instance_id)

    instance.send(attachment_name).reprocess!    
  end
end