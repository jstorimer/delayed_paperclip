require 'test/unit'

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

