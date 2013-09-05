require "bundler/gem_tasks"
require 'rake/testtask'
require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
end

Rake::TestTask.new do |t|
  t.libs << 'test'
end
