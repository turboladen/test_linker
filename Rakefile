require 'rubygems'
require 'bundler'
require 'bundler/gem_tasks'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end
task :test => :spec

Cucumber::Rake::Task.new(:features)
YARD::Rake::YardocTask.new
