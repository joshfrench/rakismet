require 'net/http'
require 'uri'

module Rakismet
  class Base
    cattr_accessor :valid_key, :rakismet_binding
    
    class << self
      def validate_key
        validate_constants
        akismet = URI.parse('http://rest.akismet.com/1.1/verify-key')
        _, valid = Net::HTTP.start(akismet.host) do |http|
          data = "key=#{Rakismet::KEY}&blog=#{Rakismet::URL}"
          http.post(akismet.path, data, Rakismet::HEADERS)
        end
        self.valid_key = (valid == 'valid')
      end
      
      def valid_key?
        @@valid_key == true
      end
      
      def akismet_call(function, args={})
        validate_constants
        args.merge!(:blog => Rakismet::URL)
        akismet = URI.parse("http://#{Rakismet::KEY}.rest.akismet.com/1.1/#{function}")
        _, response = Net::HTTP.start(akismet.host) do |http|
          data = args.map { |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
          http.post(akismet.path, data, Rakismet::HEADERS)
        end
        response
      end
      
      protected
        
        def validate_constants
          raise Undefined, "Rakismet::KEY is not defined" if Rakismet::KEY.blank?
          raise Undefined, "Rakismet::URL is not defined" if Rakismet::URL.blank?
        end
    end
  end
  
  Undefined = Class.new(NameError)
  NoBinding = Class.new(NameError)
  
  HEADERS = {
    'User-Agent' => "Rails/#{Rails::VERSION::STRING} | Rakismet/0.2.2",
    'Content-Type' => 'application/x-www-form-urlencoded'
  }
end