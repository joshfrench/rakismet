require 'net/http'
require 'uri'
require 'yaml'

require 'rakismet/model'
require 'rakismet/filter'
require 'rakismet/controller'

require 'rakismet/railtie.rb' if defined?(Rails)

module Rakismet
  class << self
    attr_accessor :key, :url, :host
  end

  def self.version
    @version ||= begin
      version = YAML.load_file(File.join(File.dirname(__FILE__), %w(.. VERSION.yml)))
      [version[:major], version[:minor], version[:patch]].join('.')
    end
  end


  def self.headers
    { 'User-Agent' => "Rails/#{Rails.version} | Rakismet/#{Rakismet.version}",
      'Content-Type' => 'application/x-www-form-urlencoded' }
  end

  class Base
    cattr_accessor :valid_key, :current_request

    class << self
      def validate_key
        validate_constants
        akismet = URI.parse(verify_url)
        _, valid = Net::HTTP.start(akismet.host) do |http|
          data = "key=#{Rakismet.key}&blog=#{Rakismet.url}"
          http.post(akismet.path, data, Rakismet.headers)
        end
        self.valid_key = (valid == 'valid')
      end

      def valid_key?
        @@valid_key == true
      end

      def akismet_call(function, args={})
        validate_constants
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

        def validate_constants
          raise Undefined, "Rakismet.key is not defined"  if Rakismet.key.blank?
          raise Undefined, "Rakismet.url is not defined"  if Rakismet.url.blank?
          raise Undefined, "Rakismet.host is not defined" if Rakismet.host.blank?
        end
    end
  end

  Undefined = Class.new(NameError)

end
