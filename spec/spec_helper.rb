require File.expand_path "lib/rakismet"
require 'ostruct'

RSpec.configure do |config|
  config.mock_with :rspec
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

def empty_request
  OpenStruct.new(:user_ip => nil,
                 :user_agent => nil,
                 :referrer => nil)
end