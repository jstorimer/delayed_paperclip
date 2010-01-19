require 'test/unit'
require 'rubygems'
require 'mocha'

gem 'sqlite3-ruby'

require 'active_record'
require 'active_support'

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures") 
config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])

ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ENV  = "test"

$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'delayed', 'paperclip') 
$LOAD_PATH << File.join(ROOT, 'test') 

module ActiveRecord
  class Base
  end
end
 
require File.join(ROOT, 'lib', 'delayed_paperclip.rb')
require File.join('test_class_methods')

# def reset_table table_name, &block
#   block ||= lambda { |table| true }
#   ActiveRecord::Base.connection.create_table :dummies, {:force => true}, &block
# end
# 
# def modify_table table_name, &block
#   ActiveRecord::Base.connection.change_table :dummies, &block
# end
# 
# def rebuild_model options = {}
#   ActiveRecord::Base.connection.create_table :dummies, :force => true do |table|
#     table.column :other, :string
#     table.column :avatar_file_name, :string
#     table.column :avatar_content_type, :string
#     table.column :avatar_file_size, :integer
#     table.column :avatar_updated_at, :datetime
#   end
#   rebuild_class options
# end
