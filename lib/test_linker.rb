require_relative 'test_linker/wrapper'
require_relative 'test_linker/version'
require_relative 'test_linker/error'
require_relative 'test_linker/helpers'

require 'logger'
require 'uri'
require 'net/http'

require 'xml/libxml/xmlrpc/client'
require 'xml/libxml/xmlrpc/parser'
require 'versionomy'

class TestLinker
  include TestLinker::Wrapper
  include TestLinker::Helpers

  class << self

    # @return [Boolean] Returns if logging is enabled or not.
    def log?
      @log ||= false
    end

    # @param [Boolean] do_logging false to turn logging off; true to turn it
    #   back on.
    def log=(do_logging)
      @log = do_logging
    end

    # @return [Boolean] Returns if logging of XMLRPC requests/responses is
    #   enabled or not.
    def log_xml?
      @log_xml ||= false
    end

    # @param [Boolean] do_logging false to turn XMLRPC logging off; true to
    #   turn it back on.
    def log_xml=(do_logging)
      @log_xml = do_logging
    end

    # @return [Logger,?] Returns a Logger unless you use a different type of
    #   logging object.
    def logger
      @logger ||= Logger.new STDOUT
    end

    # @param [?] logging_object Call this to use a different type of logger
    #   than Logger.
    def logger=(logging_object)
      @logger = logging_object
    end

    # @return [Symbol] The method name to send to the logging object in order to
    #   log messages.
    def log_level
      @log_level ||= :debug
    end

    # @param [Symbol] The method name to send to the logging object in order to
    #   log messages.
    def log_level=(level)
      @log_level = level
    end

    # @param [String] message The string to log.
    def log message
      logger.send(log_level, message) if log?
    end
  end

  # Default value for timing out after not receiving an XMLRPC response from
  # the server.
  DEFAULT_TIMEOUT = 30

  # Path the the XMLRPC interface (via the xmlrpc.php file) on the server.
  DEFAULT_API_PATH = "/lib/api/xmlrpc.php"

  # @param [String] server_url URL to access TestLink API
  # @param [String] dev_key User key to access TestLink API
  # @param [Hash] options
  # @option options [String] api_path Alternate path to the xmlrpc.php file on
  #   the server.
  # @option options [Fixnum] timeout Seconds to timeout after not receiving a
  #   response from the server.
  # @option options [String] version Force a different API version.
  def initialize(server_url, dev_key, options={})
    api_path   = options[:api_path] || DEFAULT_API_PATH
    timeout    = options[:timeout] || DEFAULT_TIMEOUT
    @dev_key   = dev_key

    uri        = URI.parse(server_url)
    http       = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = timeout
    http.read_timeout = timeout
    @server    = XML::XMLRPC::Client.new(http, api_path)

    @version   = Versionomy.parse(options[:version] || api_version)
  end

  # Makes the call to the server with the given arguments.  Note that this also
  # allows for calling XMLRPC methods on the server that haven't yet been
  # implemented as Ruby methods here.
  #
  # @example Call a new method
  #   result = make_call("tl.getWidgets", { "testplanid" => 123 }, "1.5")
  #   raise TestLinker::Error, result["message"] if result["code"]
  #   return result
  # @param [String] method_name The XMLRPC method to call.
  # @param [Hash] arguments The arguments to send to the server.
  # @param [String] method_supported_in_version The version of the API the
  #   method was added.
  # @return The return type depends on the method call.
  def make_call(method_name, arguments, method_supported_in_version)
    ensure_version_is :greater_than_or_equal_to, method_supported_in_version
    TestLinker.log "API Version: #{method_supported_in_version}"
    TestLinker.log "Calling method: '#{method_name}' with args '#{arguments}'"
    parsed_response = @server.call(method_name, arguments)
    the_data = parsed_response.params.first
    TestLinker.log "Received response:"
    TestLinker.log the_data

    if @version.nil?
      return the_data
    elsif the_data.is_a?(Array) && the_data.first[:code]
      message = "#{self.class} Error #{the_data.first[:code]}: #{the_data.first[:message]}"
      raise TestLinker::Error, message
    end

    the_data
  end

  private

  # Raises if the version set in @version doesn't meet the comparison with the
  # passed-in version.  Returns nil if @version isn't set, since there's
  # nothing to do (and something might have called to set @version).
  #
  # @private
  # @param [Symbol] comparison
  # @param [String] version
  def ensure_version_is(comparison, version)
    message = "Method not supported in version #{@version}."

    if @version.nil?
      return
    elsif comparison == :less_than && @version >= version
      raise TestLinker::Error, message
    elsif comparison == :greater_than_or_equal_to && @version < version
      raise TestLinker::Error, message
    end
  end
end
