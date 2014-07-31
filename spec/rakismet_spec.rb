require 'spec_helper'

describe Rakismet do

  def mock_response(body)
    double(:response, :body => body)
  end
  let(:http) { double(:http, :post => mock_response('akismet response')) }

  before do
    Rakismet.key = 'dummy-key'
    Rakismet.url = 'test.localhost'
    Rakismet.host = 'endpoint.localhost'
  end

  describe "proxy host" do
    it "should have proxy host and port as nil by default" do
      expect(Rakismet.proxy_host).to be_nil
      expect(Rakismet.proxy_port).to be_nil
    end
  end

  describe "url" do
    it "should allow url to be a string" do
      Rakismet.url = "string.example.com"
      expect(Rakismet.url).to eql("string.example.com")
    end

    it "should allow url to be a proc" do
      Rakismet.url = Proc.new { "proc.example.com" }
      expect(Rakismet.url).to eql("proc.example.com")
    end
  end

  describe ".validate_config" do
    it "should raise an error if key is not found" do
      Rakismet.key = ''
      expect{ Rakismet.send(:validate_config) }.to raise_error(Rakismet::Undefined)
    end

    it "should raise an error if url is not found" do
      Rakismet.url = ''
      expect{ Rakismet.send(:validate_config) }.to raise_error(Rakismet::Undefined)
    end

    it "should raise an error if host is not found" do
      Rakismet.host = ''
      expect{ Rakismet.send(:validate_config) }.to raise_error(Rakismet::Undefined)
    end
  end

  describe ".validate_key" do
    before (:each) do
      @proxy = double(Net::HTTP)
      Net::HTTP.stub(:Proxy).and_return(@proxy)
    end

    it "should use proxy host and port" do
      Rakismet.proxy_host = 'proxy_host'
      Rakismet.proxy_port = 'proxy_port'
      @proxy.stub(:start).and_return(mock_response('valid'))
      Net::HTTP.should_receive(:Proxy).with('proxy_host', 'proxy_port').and_return(@proxy)
      Rakismet.validate_key
    end

    it "should set @@valid_key = true if key is valid" do
      @proxy.stub(:start).and_return(mock_response('valid'))
      Rakismet.validate_key
      expect(Rakismet.valid_key?).to be true
    end

    it "should set @@valid_key = false if key is invalid" do
      @proxy.stub(:start).and_return(mock_response('invalid'))
      Rakismet.validate_key
      expect(Rakismet.valid_key?).to be false
    end

    it "should build url with host" do
      host = "api.antispam.typepad.com"
      Rakismet.host = host
      @proxy.should_receive(:start).with(host).and_yield(http)
      Rakismet.validate_key
    end
  end

  describe '.excluded_headers' do
    it "should default to ['HTTP_COOKIE']" do
      expect(Rakismet.excluded_headers).to eq ['HTTP_COOKIE']
    end
  end

  describe ".akismet_call" do
    before do
      @proxy = double(Net::HTTP)
      Net::HTTP.stub(:Proxy).and_return(@proxy)
      @proxy.stub(:start).and_yield(http)
    end

    it "should use proxy host and port" do
      Rakismet.proxy_host = 'proxy_host'
      Rakismet.proxy_port = 'proxy_port'
      @proxy.stub(:start).and_return(mock_response('valid'))
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

    it "should default to not being in test mode" do
      http.should_receive(:post).with(anything, %r(is_test=0), anything)
      Rakismet.send(:akismet_call, 'bogus-function')
    end

    it "should be in test mode when configured" do
      Rakismet.test = true
      http.should_receive(:post).with(anything, %r(is_test=1), anything)
      Rakismet.send(:akismet_call, 'bogus-function')
    end

    it "should return response.body" do
      expect(Rakismet.send(:akismet_call, 'bogus-function')).to eql('akismet response')
    end

    it "should build query string when params are nil" do
      expect{Rakismet.send(:akismet_call, 'bogus-function', { :nil_param => nil })}.not_to raise_error
    end
  end

end
