require File.dirname(__FILE__) + '/../spec_helper'

describe Rakismet::Base do

  let(:http) { double(:http, :to_ary => [nil, 'akismet response']).as_null_object }

  after do
    Rakismet.key = 'dummy-key'
    Rakismet.url = 'test.localhost'
    Rakismet.host = 'endpoint.localhost'
  end

  describe ".validate_config" do
    it "should raise an error if key is not found" do
      Rakismet.key = ''
      lambda { Rakismet::Base.send(:validate_config) }.should raise_error(Rakismet::Undefined)
    end

    it "should raise an error if url is not found" do
      Rakismet.url = ''
      lambda { Rakismet::Base.send(:validate_config) }.should raise_error(Rakismet::Undefined)
    end

    it "should raise an error if host is not found" do
      Rakismet.host = ''
      lambda { Rakismet::Base.send(:validate_config) }.should raise_error(Rakismet::Undefined)
    end
  end
  
  describe ".validate_key" do
    it "should set @@valid_key = true if key is valid" do
      Net::HTTP.stub!(:start).and_return([nil, 'valid'])
      Rakismet::Base.validate_key
      Rakismet::Base.valid_key?.should be_true
    end

    it "should set @@valid_key = false if key is invalid" do
      Net::HTTP.stub!(:start).and_return([nil, 'invalid'])
      Rakismet::Base.validate_key
      Rakismet::Base.valid_key?.should be_false
    end

    it "should build url with host" do
      host = "api.antispam.typepad.com"
      Rakismet.host = host
      Net::HTTP.should_receive(:start).with(host).and_yield(http)
      Rakismet::Base.validate_key
    end
  end
  
  describe ".akismet_call" do
    before do
      Net::HTTP.stub(:start).and_yield(http)
    end
    
    it "should build url with API key for the correct host" do
      host = 'api.antispam.typepad.com'
      Rakismet.host = host
      Net::HTTP.should_receive(:start).with("#{Rakismet.key}.#{host}")
      Rakismet::Base.send(:akismet_call, 'bogus-function')
    end
    
    it "should post data to named function" do
      http.should_receive(:post).with('/1.1/bogus-function', %r(foo=#{CGI.escape 'escape//this'}), Rakismet.headers)
      Rakismet::Base.send(:akismet_call, 'bogus-function', { :foo => 'escape//this' })
    end
    
    it "should return response.body" do
      #Net::HTTP.stub!(:start).and_return([nil, 'akismet response'])
      Rakismet::Base.send(:akismet_call, 'bogus-function').should eql('akismet response')
    end

    it "should build query string when params are nil" do
      lambda {
        Rakismet::Base.send(:akismet_call, 'bogus-function', { :nil_param => nil })
      }.should_not raise_error(NoMethodError)
    end
  end
  
end
