require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fakeweb'

def register_body(body)
  FakeWeb.register_uri(:post, 'http://testing/lib/api/xmlrpc.php',
      :content_type => 'text/xml', :body => body )
end

describe TestLinker::Wrapper do
  after :each do
    FakeWeb.clean_registry
  end
  
  describe "#about" do
    it "gets the about string from the server" do
      body = "<?xml version=\"1.0\"?>\n<methodResponse>\n  <params>\n    <param>\n      <value>\n        <string> Testlink API Version: 1.0 initially written by Asiel Brumfield\n with contributions by TestLink development Team</string>\n      </value>\n    </param>\n  </params>\n</methodResponse>\n"
      register_body(body)
      tl = TestLinker.new "http://testing", "devkey"
      tl.about.should == " Testlink API Version: 1.0 initially written by Asiel Brumfield\n with contributions by TestLink development Team"
    end
  end
end