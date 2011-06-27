require 'net/http'
require 'uri'
require 'cgi'
require 'yaml'

require 'rakismet/model'
require 'rakismet/middleware'

require 'rakismet/railtie.rb' if defined?(Rails)

module Rakismet
  Request = Struct.new(:user_ip, :user_agent, :referrer)
  Undefined = Class.new(NameError)

  class << self
    attr_accessor :key, :url, :host, :proxy_host, :proxy_port

    def request
      @request ||= Request.new
    end

    def set_request_vars(env)
      request.user_ip, request.user_agent, request.referrer =
        env['REMOTE_ADDR'], env['HTTP_USER_AGENT'], env['HTTP_REFERER']
    end

    def clear_request
      @request = Request.new
    end

    def version
      @version ||= begin
        version = YAML.load_file(File.join(File.dirname(__FILE__), %w(.. VERSION.yml)))
        [version[:major], version[:minor], version[:patch]].join('.')
      end
    end

    def headers
      @headers ||= begin
        user_agent = "Rakismet/#{Rakismet.version}"
        user_agent = "Rails/#{Rails.version} | " + user_agent if defined?(Rails)
        { 'User-Agent' => user_agent, 'Content-Type' => 'application/x-www-form-urlencoded' }
      end
    end

    def validate_key
      validate_config
      akismet = URI.parse(verify_url)
      _, valid = Net::HTTP::Proxy(proxy_host, proxy_port).start(akismet.host) do |http|
        data = "key=#{Rakismet.key}&blog=#{Rakismet.url}"
        http.post(akismet.path, data, Rakismet.headers)
      end
      @valid_key = (valid == 'valid')
    end

    def valid_key?
      @valid_key == true
    end

    def akismet_call(function, args={})
      validate_config
      args.merge!(:blog => Rakismet.url)
      akismet = URI.parse(call_url(function))
      _, response = Net::HTTP::Proxy(proxy_host, proxy_port).start(akismet.host) do |http|
        data = args.map { |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
        http.post(akismet.path, data, Rakismet.headers)
      end
      response
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
  end

end
