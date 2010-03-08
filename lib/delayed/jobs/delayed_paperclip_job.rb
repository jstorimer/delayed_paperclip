class DelayedPaperclipJob < Struct.new(:instance_klass, :instance_id, :attachment_name)
  def perform
    instance = instance_klass.constantize.find(instance_id)

    instance.send("#{attachment_name}_processed!")
    begin
      instance.send(attachment_name).reprocess!
    rescue Exception => e
      instance.send("#{attachment_name}_processing!", :save => true)
      
      # DJ will now pickup this error and do its error handling
      raise(e)
    end
  end
end