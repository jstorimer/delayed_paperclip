require 'rake'
require 'rake/testtask'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the paperclip plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib:test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

