require File.dirname(__FILE__) + '/spec_helper'

describe Rakismet do

  let(:http) { double(:http, :to_ary => [nil, 'akismet response']).as_null_object }

  after do
    Rakismet.key = 'dummy-key'
    Rakismet.url = 'test.localhost'
    Rakismet.host = 'endpoint.localhost'
  end
  
  describe "proxy host" do
    it "should have proxy host and port as nil by default" do
      Rakismet.proxy_host.should be_nil
      Rakismet.proxy_port.should be_nil
    end
  end

  describe ".validate_config" do
    it "should raise an error if key is not found" do
      Rakismet.key = ''
      lambda { Rakismet.send(:validate_config) }.should raise_error(Rakismet::Undefined)
    end

    it "should raise an error if url is not found" do
      Rakismet.url = ''
      lambda { Rakismet.send(:validate_config) }.should raise_error(Rakismet::Undefined)
    end

    it "should raise an error if host is not found" do
      Rakismet.host = ''
      lambda { Rakismet.send(:validate_config) }.should raise_error(Rakismet::Undefined)
    end
  end
  
  describe ".validate_key" do
    before (:each) do
      @proxy = mock(Net::HTTP)
      Net::HTTP.stub!(:Proxy).and_return(@proxy)
    end
    
    it "should use proxy host and port" do
      Rakismet.proxy_host = 'proxy_host'
      Rakismet.proxy_port = 'proxy_port'
      @proxy.stub!(:start).and_return([nil, 'valid'])
      Net::HTTP.should_receive(:Proxy).with('proxy_host', 'proxy_port').and_return(@proxy)
      Rakismet.validate_key
    end
    
    it "should set @@valid_key = true if key is valid" do
      @proxy.stub!(:start).and_return([nil, 'valid'])
      Rakismet.validate_key
      Rakismet.valid_key?.should be_true
    end

    it "should set @@valid_key = false if key is invalid" do
      @proxy.stub!(:start).and_return([nil, 'invalid'])
      Rakismet.validate_key
      Rakismet.valid_key?.should be_false
    end

    it "should build url with host" do
      host = "api.antispam.typepad.com"
      Rakismet.host = host
      @proxy.should_receive(:start).with(host).and_yield(http)
      Rakismet.validate_key
    end
  end
  
  describe ".akismet_call" do
    before do
      @proxy = mock(Net::HTTP)
      Net::HTTP.stub!(:Proxy).and_return(@proxy)
      @proxy.stub(:start).and_yield(http)
    end
    
    it "should use proxy host and port" do
      Rakismet.proxy_host = 'proxy_host'
      Rakismet.proxy_port = 'proxy_port'
      @proxy.stub!(:start).and_return([nil, 'valid'])
      Net::HTTP.should_receive(:Proxy).with('proxy_host', 'proxy_port').and_return(@proxy)
      Rakismet.send(:akismet_call, 'bogus-function')
    end
    
    it "should build url with API key for the correct host" do
      host = 'api.antispam.typepad.com'
      Rakismet.host = host
      @proxy.should_receive(:start).with("#{Rakismet.key}.#{host}")
      Rakismet.send(:akismet_call, 'bogus-function')
    end
    
    it "should post data to named function" do
      http.should_receive(:post).with('/1.1/bogus-function', %r(foo=#{CGI.escape 'escape//this'}), Rakismet.headers)
      Rakismet.send(:akismet_call, 'bogus-function', { :foo => 'escape//this' })
    end
    
    it "should return response.body" do
      Rakismet.send(:akismet_call, 'bogus-function').should eql('akismet response')
    end

    it "should build query string when params are nil" do
      lambda {
        Rakismet.send(:akismet_call, 'bogus-function', { :nil_param => nil })
      }.should_not raise_error(NoMethodError)
    end
  end
  
end
