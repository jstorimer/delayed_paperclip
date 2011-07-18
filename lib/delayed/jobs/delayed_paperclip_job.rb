class DelayedPaperclipJob < Struct.new(:instance_klass, :instance_id, :attachment_name, :style)
  
  def enqueue(job)
    instance.send("#{attachment_name}_enqueue", job) if instance.respond_to?("#{attachment_name}_enqueue")
  end

  def perform
    process_job do
      instance.send(:"#{attachment_name}").send(:reprocess!, :"#{style}")
      instance.send("#{attachment_name}_processed!")
    end
  end
  
  def before(job)
    instance.send("#{attachment_name}_before", job) if instance.respond_to?("#{attachment_name}_before")
  end

  def after(job)
    instance.send("#{attachment_name}_after", job) if instance.respond_to?("#{attachment_name}_after")
  end

  def success(job)
    instance.send("#{attachment_name}_success", job) if instance.respond_to?("#{attachment_name}_success")
  end

  def error(job, exception)
    instance.send("#{attachment_name}_error", job, exception) if instance.respond_to?("#{attachment_name}_error")
  end

  def failure
    instance.send("#{attachment_name}_failure") if instance.respond_to?("#{attachment_name}_failure")
  end
  
  private
  def instance
    @instance ||= instance_klass.constantize.find(instance_id)
  end
  
  def process_job
    instance.send(attachment_name).job_is_processing = true
    yield
    instance.send(attachment_name).job_is_processing = false    
  end
end