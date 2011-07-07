require 'spec_helper'

describe TestLinker do
  it "should have a VERSION constant" do
    TestLinker.const_get('VERSION').should_not be_empty
  end

  it "has logging turned off by default" do
    TestLinker.log?.should be_false
  end

  it "can change logging to on" do
    TestLinker.log = true
    TestLinker.log?.should == true
    TestLinker.log = false
  end

  it "has log_level set to :debug by default" do
    TestLinker.log_level.should == :debug
  end

  it "can change log_level set to :info" do
    TestLinker.log_level = :info
    TestLinker.log_level.should == :info
    TestLinker.log_level = :debug
  end
  
  it "handles TestLink errors" do
    body = <<-XML
<?xml version=\"1.0\"?>
<methodResponse>
  <params>
    <param>
      <value>
        <array><data>
  <value><struct>
  <member><name>code</name><value><int>2000</int></value></member>
  <member><name>message</name><value><string>Can not authenticate client: invalid developer key</string></value></member>
</struct></value>
</data></array>
      </value>
    </param>
  </params>
</methodResponse>

    XML
    register_body("http://testlink19", body)
    expect { TestLinker.new "http://testing", "devkey" }.to
      raise_error(TestLinker::Error,
      "2000: Can not authenticate client: invalid developer key")
    FakeWeb.clean_registry
  end
end
