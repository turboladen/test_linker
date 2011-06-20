$:.push File.expand_path("../lib", __FILE__)
require 'test_linker'

Gem::Specification.new do |s|
  s.name = %q{test_linker}
  s.version = TestLinker::VERSION

  s.required_rubygems_version = ">=1.6.2"
  s.authors = ["turboladen"]
  s.date = %q{2011-06-19}
  s.description = %q{This is a Ruby wrapper around the TestLink XMLRPC API, thus allowing access to
  your TestLink test projects, plans, cases, and results using Ruby.  We've added
  a few helper methods as well to allow for getting at more of your data a little
  easier.  This supports TestLink APIs 1.0 Beta 5 (from TestLink 1.8.x) and 1.0
  (from TestLink 1.9.x)..}
  s.email = %q{steve.loveless@gmail.com}
  s.extra_rdoc_files = [
    "ChangeLog.rdoc",
    "LICENSE.rdoc",
    "README.rdoc"
  ]
  s.files = Dir.glob("{spec,features,lib}/**/*") +
      %w(.document .gemtest .yardopts ChangeLog.rdoc Gemfile LICENSE.rdoc README.rdoc
        Rakefile)
  s.homepage = %q{http://github.com/turboladen/test_linker}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{An interface to the TestLink XMLRPC API}

  s.add_runtime_dependency(%q<versionomy>, ["~> 0.4.0"])

  s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
  s.add_development_dependency(%q<cucumber>, ["~> 0.10.0"])
  s.add_development_dependency(%q<fakeweb>, ["~> 1.3.0"])
  s.add_development_dependency(%q<rspec>, ["~> 2.6"])
  s.add_development_dependency(%q<yard>, ["~> 0.7.0"])
  if RUBY_VERSION >= "1.9"
    s.add_development_dependency(%q<simplecov>, [">= 0.4.0"])
  end
end

