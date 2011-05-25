require 'logger'
require 'rubygems'
require 'versionomy'

require File.expand_path(File.dirname(__FILE__) + '/core_ext/hash_patch')
require File.expand_path(File.dirname(__FILE__) + '/test_linker/wrapper')
require File.expand_path(File.dirname(__FILE__) + '/test_linker/version')
require File.expand_path(File.dirname(__FILE__) + '/test_linker/error')
require File.expand_path(File.dirname(__FILE__) + '/test_linker/helpers')
require File.expand_path(File.dirname(__FILE__) + '/core_ext/xmlrpc_client_patch')

class TestLinker
  include TestLinker::Wrapper
  include TestLinker::Helpers

  class << self
    XMLRPC_CLIENTS = [:noko_client, :xmlrpc]

    def xmlrpc_client=(new_client)
      unless XMLRPC_CLIENTS.include? new_client
        raise Error, "Invalid XMLRPC Client type.  Available types: #{XMLRPC_CLIENTS}"
      end

      if new_client == :noko_client
        require File.expand_path(File.dirname(__FILE__) + '/test_linker/noko_client')
        @xmlrpc_client = :noko_client
      end
    end

    def xmlrpc_client
      @xmlrpc_client ||= :xmlrpc
    end

    # @return [Boolean] Returns if logging is enabled or not.
    def log?
      @log ||= false
    end

    # @param [Boolean] do_logging false to turn logging off; true to turn it
    #   back on.
    def log=(do_logging)
      @log = do_logging
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
    server_url = server_url + api_path
    
    if TestLinker.xmlrpc_client == :noko_client
      @server   = TestLinker::NokoClient.new(server_url, timeout)
    else
      @server    = XMLRPC::Client.new_from_uri(server_url, nil, timeout)
    end
    
    @version   = Versionomy.parse(options[:version] || api_version)
  end

  # @return [Boolean] Returns if logging of XMLRPC requests/responses is
  #   enabled or not.
  def log_xml?
    @log_xml ||= false
  end

  # @param [Boolean] do_logging false to turn XMLRPC logging off; true to
  #   turn it back on.
  def log_xml=(do_logging)
    if do_logging == true
      puts "WARNING: Net::HTTP warns against using this in production, so you probably shouldn't!!"
      @server.set_debug(TestLinker.logger)
    elsif do_logging == false
      @server.set_debug(nil)
    end

    @log_xml = do_logging
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
    
    arguments.merge!({ :devKey => @dev_key }) unless arguments.has_key? :devKey
    
    TestLinker.log "API Version: #{method_supported_in_version}"
    TestLinker.log "Calling method: '#{method_name}' with args '#{arguments.inspect}'"
    response = @server.call(method_name, arguments)
    
    TestLinker.log "response class: #{response.class}"
    if response.is_a?(Array) && response.first.is_a?(Hash)
      response.each { |r| r.symbolize_keys! }
    elsif response.is_a? Hash
      response.symbolize_keys!
    end

    TestLinker.log "Received response:"
    TestLinker.log response

    if @version.nil?
      return response
    elsif response.is_a?(Array) && response.first[:code]
      raise TestLinker::Error, "#{response.first[:code]}: #{response.first[:message]}"
    end
    
    response
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
