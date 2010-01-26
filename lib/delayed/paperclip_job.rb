class DelayedPaperclipJob < Struct.new(:instance_id, :instance_klass, :attachment_name)
  def perform
    instance_klass.constantize.find(instance_id).send(attachment_name).reprocess!
  end
end