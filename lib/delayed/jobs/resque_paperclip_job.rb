class ResquePaperclipJob
  @queue = :paperclip

  def self.perform(instance_klass, instance_id, attachment_name)
    instance = instance_klass.constantize.find(instance_id)

    instance.send("#{attachment_name}_processed!")
    begin
      instance.send(attachment_name).reprocess!
    rescue Object => e
      instance.send("#{attachment_name}_processing!", :save => true)
      
      # Hand the error off to Resque
      raise(e)
    end
  end
end