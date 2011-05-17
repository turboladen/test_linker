require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'

$:.unshift Dir.pwd + "/lib"
require 'test_linker'
require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "test_linker"
  gem.version = TestLinker::VERSION
  gem.homepage = "http://github.com/turboladen/test_linker"
  gem.license = "MIT"
  gem.summary = %Q{An interface to the TestLink XMLRPC API}
  gem.description = %Q{This is a Ruby wrapper around the TestLink XMLRPC API, thus allowing access to
  your TestLink test projects, plans, cases, and results using Ruby.  We've added
  a few helper methods as well to allow for getting at more of your data a little
  easier.  This supports TestLink APIs 1.0 Beta 5 (from TestLink 1.8.x) and 1.0
  (from TestLink 1.9.x)..}
  gem.email = "steve.loveless@gmail.com"
  gem.authors = ["turboladen"]
  gem.add_bundler_dependencies
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new