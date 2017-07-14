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

    def key
      @key.is_a?(Proc) ? @key.call : @key
    end
    
    def url
      @url.is_a?(Proc) ? @url.call : @url
    end
    
    def host
      @host.is_a?(Proc) ? @host.call : @host
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

        if defined?(Rails) && Rails.respond_to?(:version)
          user_agent = "Rails/#{Rails.version} | " + user_agent
        end

        { 'User-Agent' => user_agent, 'Content-Type' => 'application/x-www-form-urlencoded' }
      end
    end

    def validate_key
      validate_config
      akismet = URI.parse(verify_url)
      response = Net::HTTP.start(akismet.host, use_ssl: true, p_addr: proxy_host, p_port: proxy_port) do |http|
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
      response = Net::HTTP.start(akismet.host, use_ssl: true, p_addr: proxy_host, p_port: proxy_port) do |http|
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
      "https://#{Rakismet.host}/1.1/verify-key"
    end

    def call_url(function)
      "https://#{Rakismet.key}.#{Rakismet.host}/1.1/#{function}"
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
