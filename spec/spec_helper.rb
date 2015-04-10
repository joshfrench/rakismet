require File.expand_path "lib/rakismet"
require 'ostruct'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:all) do
    Rakismet.key = '123'
    Rakismet.url = 'http://test.host'
    Rakismet.host = 'rest.akismet.com'
  end
end

class AkismetModel
  include Rakismet::Model
end

def comment_attrs(attrs={})
  { :comment_type => 'test', :author => 'Rails test',
    :author_email => 'test@test.host', :author_url => 'test.host',
    :content => 'comment content', :blog => Rakismet.url }.merge(attrs)
end

def akismet_attrs(attrs={})
  { :comment_type => 'test', :comment_author_email => 'test@test.host',
    :comment_author => 'Rails test', :comment_author_url => 'test.host',
    :comment_content => 'comment content' }.merge(attrs)
end

def request
  OpenStruct.new(:user_ip => '127.0.0.1',
                 :user_agent => 'RSpec',
                 :referrer => 'http://test.host/referrer')
end

def request_with_headers
  OpenStruct.new(:user_ip => '127.0.0.1',
                 :user_agent => 'RSpec',
                 :referrer => 'http://test.host/referrer',
                 :http_headers => { 'HTTP_USER_AGENT' => 'RSpec', 'HTTP_REFERER' => 'http://test.host/referrer' } )
end

def empty_request
  OpenStruct.new(:user_ip => nil,
                 :user_agent => nil,
                 :referrer => nil,
                 :http_headers => nil)
end