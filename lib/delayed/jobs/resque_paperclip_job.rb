class ResquePaperclipJob
  @queue = :paperclip

  def self.perform(instance_klass, instance_id, attachment_name)
    instance = instance_klass.constantize.find(instance_id)

    instance.send(attachment_name).reprocess!

    instance.send("#{attachment_name}_processed!") if instance.respond_to?("#{attachment_name}_processed!")
  end
end