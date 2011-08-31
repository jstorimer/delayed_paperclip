require 'rubygems'
require 'test/unit'
require 'mocha'
require 'active_record'
require 'logger'
require 'sqlite3'
require 'paperclip/railtie'
Paperclip::Railtie.insert

ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
$LOAD_PATH << File.join(ROOT, 'lib')

require 'delayed_paperclip'

class Test::Unit::TestCase
  def setup
    silence_warnings do
      Object.const_set(:Rails, stub('Rails', :root => ROOT, :env => 'test'))
    end
  end
end

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures")
config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])

def reset_dummy(with_processed = false)
  build_dummy_table(with_processed)

  reset_class "Dummy"

  @dummy = Dummy.new(:image => File.open("#{ROOT}/test/fixtures/12k.png"))
end

def reset_class class_name, include_process = true
  Object.send(:remove_const, class_name) rescue nil
  klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))
  klass.class_eval do
    include Paperclip::Glue
    has_attached_file     :image
    process_in_background :image if include_process
  end
  klass.reset_column_information
  @dummy_class = klass
end

def build_dummy_table(with_processed)
  ActiveRecord::Base.connection.create_table :dummies, :force => true do |t|
    t.string   :image_file_name
    t.string   :image_content_type
    t.integer  :image_file_size
    t.datetime :image_updated_at
    t.boolean(:image_processing, :default => false) if with_processed
  end
end

def build_delayed_jobs
  ActiveRecord::Base.connection.create_table :delayed_jobs, :force => true do |table|
    table.integer  :priority, :default => 0      # Allows some jobs to jump to the front of the queue
    table.integer  :attempts, :default => 0      # Provides for retries, but still fail eventually.
    table.text     :handler                      # YAML-encoded string of the object that will do work
    table.string   :last_error                   # reason for last failure (See Note below)
    table.datetime :run_at                       # When to run. Could be Time.now for immediately, or sometime in the future.
    table.datetime :locked_at                    # Set when a client is working on this object
    table.datetime :failed_at                    # Set when all retries have failed (actually, by default, the record is deleted instead)
    table.string   :locked_by                    # Who is working on this object (if locked)
    table.timestamps
  end
end
