require "base64"
require "time"
require "excon"
require "uri"
require "zlib"
require 'openssl'
require 'yaml'                  #COMMON YML

# open it up when needed. This will be needed when a new customer onboarded via pug.
require "securerandom"

__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), ".."))
unless $LOAD_PATH.include?(__LIB_DIR__)
$LOAD_PATH.unshift(__LIB_DIR__)
end

require "megam/api/errors"
require "megam/api/version"
require "megam/api/login"
require "megam/api/accounts"
require "megam/api/nodes"
require "megam/api/appdefns"
require "megam/api/app_request"
require "megam/api/bolt_request"
require "megam/api/boltdefns"
require "megam/api/requests"
require "megam/api/predefs"
require "megam/api/predef_clouds"
require "megam/api/cloud_tools"
require "megam/api/cloud_tool_settings"
require "megam/api/sshkeys"
require "megam/api/marketplaces"
require "megam/api/marketplace_addons"
<<<<<<< HEAD
require "megam/api/organizations"
require "megam/api/domains"
=======
require "megam/api/csars"
>>>>>>> origin/0.5
require "megam/core/server_api"
require "megam/core/config"
require "megam/core/stuff"
require "megam/core/text"
require "megam/core/log"
require "megam/core/json_compat"
require "megam/builder/make_node"
require "megam/builder/delete_node"
require "megam/core/auth"
require "megam/core/error"
require "megam/core/account"
require "megam/core/node"
require "megam/core/appdefns"
require "megam/core/app_request"
require "megam/core/bolt_request"
require "megam/core/boltdefns"
require "megam/core/node_collection"
require "megam/core/appdefns_collection"
require "megam/core/app_request_collection"
require "megam/core/bolt_request_collection"
require "megam/core/boltdefns_collection"
require "megam/core/request"
require "megam/core/request_collection"
require "megam/core/predef"
require "megam/core/predef_collection"
require "megam/core/predefcloud"
require "megam/core/predefcloud_collection"
require "megam/core/cloudtool"
require "megam/core/cloudtool_collection"
require "megam/core/cloudtemplate"
require "megam/core/cloudtemplate_collection"
require "megam/core/cloudinstruction_group"
require "megam/core/cloudinstruction_collection"
require "megam/core/cloudinstruction"
require "megam/core/cloudtoolsetting"
require "megam/core/cloudtoolsetting_collection"
require "megam/core/sshkey"
require "megam/core/sshkey_collection"
require "megam/core/marketplace"
require "megam/core/marketplace_collection"
require "megam/core/marketplace_addon"
require "megam/core/marketplace_addon_collection"
<<<<<<< HEAD
require "megam/core/organizations"
require "megam/core/domains"

#we may nuke logs out of the api
#require "megam/api/logs"

=======
require "megam/core/csar"
require "megam/core/csar_collection"
require "megam/core/konipai"
>>>>>>> origin/0.5


module Megam
  class API

    #text is used to print stuff in the terminal (message, log, info, warn etc.)
    attr_accessor :text

    API_MEGAM_CO = "api.megam.co".freeze
    API_VERSION2 = "/v2".freeze

    X_Megam_DATE = "X-Megam-DATE".freeze
    X_Megam_HMAC = "X-Megam-HMAC".freeze
    X_Megam_OTTAI = "X-Megam-OTTAI".freeze

    HEADERS = {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip',
      'User-Agent' => "megam-api/#{Megam::API::VERSION}",
      'X-Ruby-Version' => RUBY_VERSION,
      'X-Ruby-Platform' => RUBY_PLATFORM
    }

    OPTIONS = {
      :headers => {},
<<<<<<< HEAD
      :host => '127.0.0.1',
=======
      :host => API_MEGAM_CO,
>>>>>>> origin/0.5
      :nonblock => false,
      :scheme => 'http'
    }
<<<<<<< HEAD
    API_VERSION1 = "/v2"
=======

>>>>>>> origin/0.5

    def text
      @text ||= Megam::Text.new(STDOUT, STDERR, STDIN, {})
    end

    def last_response
      @last_response
    end

    # It is assumed that every API call will use an API_KEY/email. This ensures validity of the person
    # really the same guy on who he claims.
    # 3 levels of options exits
    # 1. The global OPTIONS as available inside the API (OPTIONS)
    # 2. The options as passed via the instantiation of API will override global options. The ones that are passed are :email and :api_key and will
    # be  merged into a class variable @options
    # 3. Upon merge of the options, the api_key, email as available in the @options is deleted.
    def initialize(options={})
      @options = OPTIONS.merge(options)
      if File.exist?("#{ENV['MEGAM_HOME']}/nilavu.yml")
          @common = YAML.load_file("#{ENV['MEGAM_HOME']}/nilavu.yml")                  #COMMON YML
          @options[:host] = "#{@common["api"]["host"]}"
          @options[:scheme] = "#{@common["api"]["scheme"]}"
        end
      @api_key = @options.delete(:api_key) || ENV['MEGAM_API_KEY']
      @email = @options.delete(:email)
      raise ArgumentError, "You must specify [:email, :api_key]" if @email.nil? || @api_key.nil?
    end

    def request(params,&block)
      just_color_debug("#{@options[:path]}")
      start = Time.now
      Megam::Log.debug("START")
      params.each do |pkey, pvalue|
        Megam::Log.debug("> #{pkey}: #{pvalue}")
      end

      begin
        response = connection.request(params, &block)
      rescue Excon::Errors::HTTPStatusError => error
        klass = case error.response.status

        when 401 then Megam::API::Errors::Unauthorized
        when 403 then Megam::API::Errors::Forbidden
        when 404 then Megam::API::Errors::NotFound
        when 408 then Megam::API::Errors::Timeout
        when 422 then Megam::API::Errors::RequestFailed
        when 423 then Megam::API::Errors::Locked
        when /50./ then Megam::API::Errors::RequestFailed
        else Megam::API::Errors::ErrorWithResponse
        end
        reerror = klass.new(error.message, error.response)
        reerror.set_backtrace(error.backtrace)
        Megam::Log.debug("#{reerror.response.body}")
        reerror.response.body = Megam::JSONCompat.from_json(reerror.response.body.chomp)
        Megam::Log.debug("RESPONSE ERR: Ruby Object")
        Megam::Log.debug("#{reerror.response.body}")
        raise(reerror)
      end

      @last_response = response
      Megam::Log.debug("RESPONSE: HTTP Status and Header Data")
      Megam::Log.debug("> HTTP #{response.remote_ip} #{response.status}")

      response.headers.each do |header, value|
        Megam::Log.debug("> #{header}: #{value}")
      end
      Megam::Log.debug("End HTTP Status/Header Data.")

      if response.body && !response.body.empty?
        if response.headers['Content-Encoding'] == 'gzip'
          Megam::Log.debug("RESPONSE: Content-Encoding is gzip")
          response.body = Zlib::GzipReader.new(StringIO.new(response.body)).read
        end
        Megam::Log.debug("RESPONSE: HTTP Body(JSON)")
        Megam::Log.debug("#{response.body}")

        begin
          unless response.headers[X_Megam_OTTAI]
            response.body = Megam::JSONCompat.from_json(response.body.chomp)
            Megam::Log.debug("RESPONSE: Ruby Object")
          else
            response.body = Megam::KoniPai.new.koni(response.body.chomp)
            Megam::Log.debug("RESPONSE: KoniPai Object ")
          end
          Megam::Log.debug("#{response.body}")
        rescue Exception => jsonerr
          Megam::Log.error(jsonerr)
          raise(jsonerr)
        end
      end
      Megam::Log.debug("END(#{(Time.now - start).to_s}s)")
      # reset (non-persistent) connection
      @connection.reset
      response
    end

    private

    def just_color_debug(path)
      text.msg "--> #{text.color('(#{path})', :cyan,:bold)}"                  # Why " inside "
    end



    #Make a lazy connection.
    def connection
      @options[:path] =API_VERSION2+ @options[:path]
      encoded_api_header = encode_header(@options)
      @options[:headers] = HEADERS.merge({
        X_Megam_HMAC => encoded_api_header[:hmac],
        X_Megam_DATE => encoded_api_header[:date],
      }).merge(@options[:headers])
<<<<<<< HEAD
                  #COMMON YML
        if @options[:scheme] == "https"
puts "=====> if https =======>"

=======

      if @options[:scheme] == "https"
>>>>>>> origin/0.5
      if !File.exist?(File.expand_path(File.join("#{ENV['MEGAM_HOME']}", "#{@common["api"]["pub_key"]}")))
        text.warn("Certificate file does not exist. SSL_VERIFY_PEER set as false")
        Excon.defaults[:ssl_verify_peer] = false
        @options[:scheme] == "http"
      elsif !File.exist?(File.expand_path(File.join(File.dirname(__FILE__), "..", "certs", "cacert.pem")))
        text.warn("Certificate file does not exist. SSL_VERIFY_PEER set as false")
        Excon.defaults[:ssl_verify_peer] = false
        @options[:scheme] == "http"
      else
        Megam::Log.debug("Certificate found")
        Excon.defaults[:ssl_verify_peer] = true
                Excon.defaults[:ssl_ca_file] = File.expand_path(File.join("#{ENV['MEGAM_HOME']}", "#{@common["api"]["pub_key"]}")) || File.expand_path(File.join(File.dirname(__FILE__), "..", "certs", "cacert.pem"))                  
      end
      end

      Megam::Log.debug("HTTP Request Data:")
      Megam::Log.debug("> HTTP #{@options[:scheme]}://#{@options[:host]}")
      @options.each do |key, value|
        Megam::Log.debug("> #{key}: #{value}")
      end
      Megam::Log.debug("End HTTP Request Data.")
      if @options[:scheme] == "https"
      @connection = Excon.new("#{@options[:scheme]}://#{@options[:host]}",@options)
      else
           Excon.defaults[:ssl_verify_peer] = false
           @connection = Excon.new("#{@options[:scheme]}://#{@options[:host]}:9000",@options)
      end
      @connection
    end

    ## encode header as per rules.
    # The input hash will have
    # :api_key, :email, :body, :path
    # The output will have
    # :hmac
    # :date
    # (Refer https://github.com/indykish/megamplay.git/test/AuthenticateSpec.scala)
    def encode_header(cmd_parms)
      header_params ={}
      body_digest = OpenSSL::Digest::MD5.digest(cmd_parms[:body])
      body_base64 = Base64.encode64(body_digest)

      current_date = Time.now.strftime("%Y-%m-%d %H:%M")

      data="#{current_date}"+"\n"+"#{cmd_parms[:path]}"+"\n"+"#{body_base64}"

      digest  = OpenSSL::Digest::Digest.new('sha1')
      movingFactor = data.rstrip!
      hash = OpenSSL::HMAC.hexdigest(digest, @api_key, movingFactor)
      final_hmac = @email+':' + hash
      header_params = { :hmac => final_hmac, :date => current_date}
    end

 end

end
