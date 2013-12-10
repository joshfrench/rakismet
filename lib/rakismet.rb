require 'net/http'
require 'uri'
require 'cgi'
require 'yaml'

require 'rakismet/model'
require 'rakismet/middleware'
require 'rakismet/version'
require 'rakismet/railtie.rb' if defined?(Rails)

module Rakismet
  Request = Struct.new(:user_ip, :user_agent, :referrer, :http_headers)
  Undefined = Class.new(NameError)

  class << self
    attr_accessor :key, :url, :host, :proxy_host, :proxy_port, :test, :excluded_headers
    
    def excluded_headers
      @excluded_headers || ['HTTP_COOKIE']
    end

    def request
      @request ||= Request.new
    end

    def url
      @url.is_a?(Proc) ? @url.call : @url
    end

    def set_request_vars(env)
      request.user_ip, request.user_agent, request.referrer =
        env['REMOTE_ADDR'], env['HTTP_USER_AGENT'], env['HTTP_REFERER']
        
      # Collect all CGI-style HTTP_ headers except cookies for privacy..
      request.http_headers = env.select { |k,v| k =~ /^HTTP_/ }.reject { |k,v| excluded_headers.include? k }
    end

    def clear_request
      @request = Request.new
    end

    def headers
      @headers ||= begin
        user_agent = "Rakismet/#{Rakismet::VERSION}"
        user_agent = "Rails/#{Rails.version} | " + user_agent if defined?(Rails)
        { 'User-Agent' => user_agent, 'Content-Type' => 'application/x-www-form-urlencoded' }
      end
    end

    def validate_key
      validate_config
      akismet = URI.parse(verify_url)
      response = Net::HTTP::Proxy(proxy_host, proxy_port).start(akismet.host) do |http|
        data = "key=#{Rakismet.key}&blog=#{Rakismet.url}"
        http.post(akismet.path, data, Rakismet.headers)
      end
      @valid_key = (response.body == 'valid')
    end

    def valid_key?
      @valid_key == true
    end

    def akismet_call(function, args={})
      validate_config
      args.merge!(:blog => Rakismet.url, :is_test => Rakismet.test_mode)
      akismet = URI.parse(call_url(function))
      response = Net::HTTP::Proxy(proxy_host, proxy_port).start(akismet.host) do |http|
        params = args.map do |k,v|
          param = v.class < String ? v.to_str : v.to_s # for ActiveSupport::SafeBuffer and Nil, respectively
          "#{k}=#{CGI.escape(param)}"
        end
        http.post(akismet.path, params.join('&'), Rakismet.headers)
      end
      response.body
    end

    protected

    def verify_url
      "http://#{Rakismet.host}/1.1/verify-key"
    end

    def call_url(function)
      "http://#{Rakismet.key}.#{Rakismet.host}/1.1/#{function}"
    end

    def validate_config
      raise Undefined, "Rakismet.key is not defined"  if Rakismet.key.nil? || Rakismet.key.empty?
      raise Undefined, "Rakismet.url is not defined"  if Rakismet.url.nil? || Rakismet.url.empty?
      raise Undefined, "Rakismet.host is not defined" if Rakismet.host.nil? || Rakismet.host.empty?
    end

    def test_mode
      test ? 1 : 0
    end
  end

end
