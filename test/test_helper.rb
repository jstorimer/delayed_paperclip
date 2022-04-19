# frozen_string_literal: true

require 'test/unit'
require 'mocha'
require 'mocha/test_unit'

ROOT       = File.expand_path('..', __dir__)
RAILS_ROOT = ROOT
$LOAD_PATH << File.join(ROOT, 'lib')

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] = RAILS_ROOT

# ignore warnings in libs themselves for ruby 2.7
if defined?(Warning)
  module WarningFilter
    def warn(msg)
      return if msg.include?('/lib/delayed/worker.rb:')
      return if msg.include?('/lib/resque.rb:')
      return if msg.include?('/lib/paperclip/') && !ENV['LOCAL_PAPERCLIP']
      super
    end
  end
  Warning.singleton_class.prepend(WarningFilter)
end

require 'rails'
require 'active_record'
require 'logger'
require 'sqlite3'
require 'paperclip/railtie'

require 'paperclip'
require 'delayed_paperclip'

class DummyApplication < Rails::Application
end

# Paperclip::Railtie.insert
# run initializer 'paperclip.railtie.configure'




require 'delayed_paperclip/railtie'
DelayedPaperclip::Railtie.insert

class DelayedPaperclip::TestCase < Test::Unit::TestCase
  def setup
    assert_equal 'test', Rails.env
    Rails.stubs(:root).returns(RAILS_ROOT)
    assert_equal File.expand_path('..', __dir__), Rails.root
    # silence_warnings do
      # Object.const_set(:Rails, stub('Rails', :root => ROOT, :env => 'test'))
    # end
  end
end

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures")
config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])
# Paperclip.logger = ActiveRecord::Base.logger

# def reset_dummy(options = {})
#   reset_dummy(options)
#   Dummy.new(:image => File.open("#{RAILS_ROOT}/test/fixtures/12k.png"))
# end

def reset_dummy(options = {})
  options[:with_processed] = true unless options.key?(:with_processed)
  build_dummy_table(options[:with_processed])
  reset_class("Dummy", options)
end

def build_dummy_table(with_processed)
  ActiveRecord::Base.connection.create_table :dummies, :force => true do |t|
    t.string   :name
    t.string   :image_file_name
    t.string   :image_content_type
    t.integer  :image_file_size
    t.datetime :image_updated_at
    t.boolean(:image_processing, :default => false) if with_processed
  end
end

def reset_class(class_name, options)
  # ActiveRecord::Base.send(:include, Paperclip::Glue)
  Object.send(:remove_const, class_name) rescue nil
  klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))
  klass.class_eval do
    # include Paperclip::Glue
    has_attached_file     :image
    process_in_background :image, options if options[:with_processed]
    after_update :reprocess if options[:with_after_update_callback]

    def reprocess
      image.reprocess!
    end
  end
  klass.reset_column_information
  klass
end

