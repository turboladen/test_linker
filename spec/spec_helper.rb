if RUBY_VERSION > '1.9'
  require 'simplecov'

  SimpleCov.start do
    add_group "Library", "lib/"
  end
end

require 'rubygems'
require 'bundler'

begin
  Bundler.setup
rescue Bundler::BundlerError => e
  STDERR.puts e.message
  STDERR.puts "Run `bundle install` to install missing gems."
  exit e.status_code
end

require 'rspec'
require 'fakeweb'
require File.expand_path(File.dirname(__FILE__) + '/../lib/test_linker')

FakeWeb.allow_net_connect = false

def register_body(url_base, body)
  #FakeWeb.register_uri(:post, 'http://testing/lib/api/xmlrpc.php',
  FakeWeb.register_uri(:post, "#{url_base}/lib/api/xmlrpc.php",
      :content_type => 'text/xml', :body => body )
end
