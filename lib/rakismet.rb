require 'net/http'
require 'uri'
require 'cgi'
require 'yaml'

require 'rakismet/model'
require 'rakismet/middleware'

require 'rakismet/railtie.rb' if defined?(Rails)

module Rakismet
  Request = Struct.new(:remote_ip, :user_agent, :referer)

  class << self
    attr_accessor :key, :url, :host

    def request
      @request ||= Request.new
    end

    def set_request_vars(env)
      request.remote_ip, request.user_agent, request.referer =
        env['REMOTE_IP'], env['USER_AGENT'], env['REFERER']
    end

    def clear_request
      @request = Request.new
    end
  end

  def self.version
    @version ||= begin
      version = YAML.load_file(File.join(File.dirname(__FILE__), %w(.. VERSION.yml)))
      [version[:major], version[:minor], version[:patch]].join('.')
    end
  end


  def self.headers
    @headers ||= begin
      user_agent = "Rakismet/#{Rakismet.version}"
      user_agent += " | Rails/#{Rails.version}" if defined?(Rails)
      { 'User-Agent' => user_agent, 'Content-Type' => 'application/x-www-form-urlencoded' }
    end
  end

  class Base

    class << self
      def validate_key
        validate_config
        akismet = URI.parse(verify_url)
        _, valid = Net::HTTP.start(akismet.host) do |http|
          data = "key=#{Rakismet.key}&blog=#{Rakismet.url}"
          http.post(akismet.path, data, Rakismet.headers)
        end
        @@valid_key = (valid == 'valid')
      end

      def valid_key?
        @@valid_key == true
      end

      def akismet_call(function, args={})
        validate_config
        args.merge!(:blog => Rakismet.url)
        akismet = URI.parse(call_url(function))
        _, response = Net::HTTP.start(akismet.host) do |http|
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

  Undefined = Class.new(NameError)

end
