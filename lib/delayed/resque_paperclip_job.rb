class ResquePaperclipJob
  @queue = :paperclip
  
  def perform(instance_klass, instance_id, attachment_name)
    instance = instance_klass.constantize.find(instance_id)

    instance.send(attachment_name).reprocess!    
  end
end