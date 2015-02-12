require "bundler/gem_tasks"
require 'rake/testtask'

desc "Run the test application on port 4567"
task :run do
  `shotgun test/test_directory_listing_app.rb -o 0.0.0.0`
end

desc "Run tests"
Rake::TestTask.new do |t|
  t.libs << 'test'
end

##
# Default -> run tests

task :default => [:test]
