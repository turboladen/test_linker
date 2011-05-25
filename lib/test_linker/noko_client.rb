require 'rest-client'
require 'nokogiri'
require File.expand_path(File.dirname(__FILE__) + "/../core_ext/hash_patch")

class TestLinker
  class NokoClient
    CONTENT_TYPE = "text/xml; charset=utf-8"

    attr_accessor :do_logging
    
    def initialize(url, timeout, do_logging=true)
      @url = url
      @timeout = timeout
      @do_logging = do_logging
    end

    def call(method_name, arguments={})
      xml = build_xml(method_name, arguments)
      http_response = RestClient.post(@url, xml, 
          :content_type => CONTENT_TYPE,
          :accept => CONTENT_TYPE)
      xml_response = Nokogiri::XML.parse(http_response.body)
      puts xml_response if @do_logging

      to_ruby(xml_response)
    end
    
    private
    
    def to_ruby(xml)
      array = []
      
      values = xml.at_xpath("//methodResponse/params/param/value").element_children
      values.each do |value|
        array << parse_type_to_ruby(value)
      end
      
      if array.length == 1 && array.first.is_a?(String)
        array.first
      else
        array
      end
    end

    def parse_type_to_ruby(m)
      case m.name
      when "struct"
        parse_struct m
      when "array"
        parse_array m
      when "i4"
        #m.text.to_i
        Integer m.text
      when "int"
        #m.text.to_i
        Integer m.text
      when "boolean"
        #m.text.to_i
        Integer m.text
      when "double"
        #m.text.to_f
        Float m.text
      when "dateTime.iso8601"
        Time.parse(m.text).utc.iso8601
      when "base64"
        m.text
      else
        m.text
      end
    end

    # @param [Nokogiri::XML::NodeSet] value_child The NodeSet that's a result of
    #   the child of a <methodResponse><params><param><value><struct>; this
    #   should be a <member>.
    # @return [Hash] The <name> of each <member> corresponds to each Hash key, and
    #   the <value> of each corresponds to each Hash value.
    def parse_struct(xmlrpc_struct)
      struct = {}
      
      xmlrpc_struct.children.each do |member|
        if member.name == "member"
          temp_key = ""
          temp_value = ""

          member.children.each do |member_child|
            if member_child.name == "name"
              temp_key = member_child.text
            elsif member_child.name == "value"
              member_child.children.each do |m|
                temp_value = parse_type_to_ruby(m)
              end
            end
          end

          struct[temp_key] = temp_value
          
        end
      end
      
      struct.symbolize_keys!
    end
    
    # Turns a Hash key to a symbol, unless it's an Integer.
    def symbolize_key(object)
      Integer(object) rescue object.to_sym
    end
    
    # @param [Nokogiri::XML::NodeSet] value_child
    # @return [Array]
    def parse_array(xmlrpc_array)
      array = []
      
      xmlrpc_array.children.each do |array_child|
        if array_child.name == "data"
          values = array_child.children
          
          values.each do |value|
            value.children.each do |value_child|
              #p parse_type_to_ruby(value_child)
              array << parse_type_to_ruby(value_child)
            end
          end
        end
      end
      
      array
    end
    
    # Uses the +method_name+ and +arguments+ to build the XML used in making
    # the XMLRPC call.
    #
    # @param [String] method_name
    # @param [Hash] arguments
    # @return [String] The XML to send as the HTTP Request body on the HTTP POST.
    def build_xml(method_name, arguments)
      xml_string = Nokogiri::XML::Builder.new do |xml|
        xml.methodCall {
          xml.methodName method_name
          xml.params {
            xml.param {
              xml.value {
                xml.struct { 
                  arguments.each_pair do |k, v|
                    xml.member {
                      xml.name k
                      #xml.value parse_type_to_xml(v)
                      xml.value {
                        #xml.text parse_type_to_xml v
                        xml.<<(parse_type_to_xml v)
                      }
                    }
                  end
                }
              }
            }
          }
        }
      end
      
      xml_string.to_xml
    end
    
    # Coverts +value+ to its XMLRPC type.
    #
    # @param value
    # @return [String] The +value+ embedded in its XMLRPC type, as a String.
    def parse_type_to_xml(value)
      puts "value: #{value}"
      
      case value.class
      when Fixnum
        "<i4>#{value}</i4>"
      when Symbol
        "<string>#{value}</string>"
      else
        "<string>#{value}</string>"
        #{ :string => value }
      end
    end
  end
end
