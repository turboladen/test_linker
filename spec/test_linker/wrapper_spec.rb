require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TestLinker::Wrapper do
  before do
    body = "<?xml version=\"1.0\"?>\n<methodResponse>\n  <params>\n    <param>\n      <value>\n        <string> Testlink API Version: 1.0 initially written by Asiel Brumfield\n with contributions by TestLink development Team</string>\n      </value>\n    </param>\n  </params>\n</methodResponse>\n"
    register_body(body)
    @tl = TestLinker.new "http://testing", "devkey"
  end
  
  after :each do
    FakeWeb.clean_registry
  end
  
  describe "#about" do
    it "gets the about string from the server" do
      @tl.about.should == " Testlink API Version: 1.0 initially written by Asiel Brumfield\n with contributions by TestLink development Team"
    end
  end
  
  describe "#say_hello" do
    it "gets the server to say 'Hello!'" do
      body = <<-XML
<?xml version=\"1.0\"?>
<methodResponse>
  <params>
    <param>
      <value>
        <string>Hello!</string>
      </value>
    </param>
  </params>
</methodResponse>

XML
      register_body(body)
      @tl.say_hello.should == "Hello!"
    end
  end
  
  describe "#project_by_name" do
    context "TestLink API 1.0 Beta 5" do
      it "should raise an error that it's not supported'" do
        pending
      end
    end
    
    context "TestLink API 1.0" do
      it "gets a project by its name" do
        body = <<-XML
<?xml version=\"1.0\"?>
<methodResponse>
  <params>
    <param>
      <value>
        <array><data>
  <value><struct>
  <member><name>id</name><value><string>123</string></value></member>
  <member><name>notes</name><value><string></string></value></member>
  <member><name>color</name><value><string></string></value></member>
  <member><name>active</name><value><string>1</string></value></member>
  <member><name>prefix</name><value><string>meow</string></value></member>
  <member><name>tc_counter</name><value><string>1899</string></value></member>
  <member><name>is_public</name><value><string>1</string></value></member>
  <member><name>options</name><value><string>O:8:&quot;stdClass&quot;:4:{s:19:&quot;requirementsEnabled&quot;;s:1:&quot;1&quot;;s:19:&quot;testPriorityEnabled&quot;;s:1:&quot;1&quot;;s:17:&quot;automationEnabled&quot;;s:1:&quot;1&quot;;s:16:&quot;inventoryEnabled&quot;;b:0;}</string></value></member>
  <member><name>name</name><value><string>Meow</string></value></member>
  <member><name>opt</name><value><struct>
  <member><name>requirementsEnabled</name><value><string>1</string></value></member>
  <member><name>testPriorityEnabled</name><value><string>1</string></value></member>
  <member><name>automationEnabled</name><value><string>1</string></value></member>
  <member><name>inventoryEnabled</name><value><boolean>0</boolean></value></member>
</struct></value></member>
</struct></value>
</data></array>
      </value>
    </param>
  </params>
</methodResponse>

        XML

        register_body(body)
        @tl.project_by_name("Meow").should == [
            { :id=>123,
              :notes=>"",
              :color=>"",
              :active=>1,
              :prefix=>"meow",
              :tc_counter=>1899,
              :is_public=>1, 
              :options=>"O:8:\"stdClass\":4:{s:19:\"requirementsEnabled\";s:1:\"1\";s:19:\"testPriorityEnabled\";s:1:\"1\";s:17:\"automationEnabled\";s:1:\"1\";s:16:\"inventoryEnabled\";b:0;}",
              :name=>"Meow", 
              :opt=> { :requirementsEnabled=>1,
                  :testPriorityEnabled=>1, 
                  :automationEnabled=>1, 
                  :inventoryEnabled=>false
              }
        }
        ]
      end
    end
  end

  describe "#projects" do
    it "gets a list of projects on the server" do
      body = <<-XML
<?xml version=\"1.0\"?>
<methodResponse>
  <params>
    <param>
      <value>
<array><data>
  <value><struct>
  <member><name>id</name><value><string>335241</string></value></member>
  <member><name>notes</name><value><string></string></value></member>
  <member><name>color</name><value><string></string></value></member>
  <member><name>active</name><value><string>1</string></value></member>
  <member><name>option_reqs</name><value><string>0</string></value></member>
  <member><name>option_priority</name><value><string>0</string></value></member>
  <member><name>prefix</name><value><string>W_UDI</string></value></member>
  <member><name>tc_counter</name><value><string>0</string></value></member>
  <member><name>option_automation</name><value><string>0</string></value></member>
  <member><name>name</name><value><string>Warehouse</string></value></member>
</struct></value>
  <value><struct>
  <member><name>id</name><value><string>465934</string></value></member>
  <member><name>notes</name><value><string></string></value></member>
  <member><name>color</name><value><string></string></value></member>
  <member><name>active</name><value><string>1</string></value></member>
  <member><name>option_reqs</name><value><string>1</string></value></member>
  <member><name>option_priority</name><value><string>1</string></value></member>
  <member><name>prefix</name><value><string>ztest</string></value></member>
  <member><name>tc_counter</name><value><string>142</string></value></member>
  <member><name>option_automation</name><value><string>1</string></value></member>
  <member><name>name</name><value><string>z_test</string></value></member>
</struct></value>
</data></array>
      </value>
    </param>
  </params>
</methodResponse>

      XML
      
      register_body(body)
      @tl.projects.should == [
          {:id=>335241, :notes=>"", :color=>"", :active=>1, :option_reqs=>0,
              :option_priority=>0, :prefix=>"W_UDI", :tc_counter=>0,
              :option_automation=>0, :name=>"Warehouse"}, 
          {:id=>465934, :notes=>"", :color=>"", :active=>1, :option_reqs=>1,
              :option_priority=>1, :prefix=>"ztest", :tc_counter=>142,
              :option_automation=>1, :name=>"z_test"}
        ]
    end
  end
  
  describe "#test_suites_for_test_plan" do
    it "gets a list of test suites" do
      body = <<-XML
<?xml version=\"1.0\"?>
<methodResponse>
  <params>
    <param>
      <value>
        <array><data>
  <value><struct>
  <member><name>name</name><value><string>Basic Functionality</string></value></member>
  <member><name>id</name><value><string>431197</string></value></member>
</struct></value>
  <value><struct>
  <member><name>name</name><value><string>Other Functionality</string></value></member>
  <member><name>id</name><value><string>429939</string></value></member>
</struct></value>
</data></array>
      </value>
    </param>
  </params>
</methodResponse>

      XML

      register_body(body)
      @tl.test_suites_for_test_plan(576096).should == [
          {:name=>"Basic Functionality", :id=>431197},
          {:name=>"Other Functionality", :id=>429939}
      ]
    end
  end
  
  describe "#test_plans" do
    it "gets a list of test plans" do
      body = <<-XML
<?xml version=\"1.0\"?>
<methodResponse>
  <params>
    <param>
      <value>
        <array><data>
  <value><struct>
  <member><name>466122</name><value><struct>
  <member><name>id</name><value><string>466122</string></value></member>
  <member><name>name</name><value><string>App 2.5.0</string></value></member>
  <member><name>notes</name><value><string></string></value></member>
  <member><name>active</name><value><string>1</string></value></member>
  <member><name>testproject_id</name><value><string>392797</string></value></member>
</struct></value></member>
  <member><name>576096</name><value><struct>
  <member><name>id</name><value><string>576096</string></value></member>
  <member><name>name</name><value><string>App 2.5.1</string></value></member>
  <member><name>notes</name><value><string></string></value></member>
  <member><name>active</name><value><string>1</string></value></member>
  <member><name>testproject_id</name><value><string>392797</string></value></member>
</struct></value></member>
</struct></value>
</data></array>
      </value>
    </param>
  </params>
</methodResponse>

      XML

      register_body(body)
      @tl.test_plans(392797).should == [
          466122=>
              {:id=>466122, :name=>"App 2.5.0", :notes=>"", :active=>1, :testproject_id=>392797},
          576096=>
              {:id=>576096, :name=>"App 2.5.1", :notes=>"", :active=>1, :testproject_id=>392797}
      ] 
    end
  end
end
