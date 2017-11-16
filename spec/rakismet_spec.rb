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
    Rakismet.proxy_host = nil
    Rakismet.proxy_port = nil

    @test_url = "#{Rakismet.key}.#{Rakismet.host}"
  end

  describe "proxy host" do
    it "should have proxy host and port as nil by default" do
      Rakismet.proxy_host.should be_nil
      Rakismet.proxy_port.should be_nil
    end
  end

  describe "url" do
    it "should allow url to be a string" do
      Rakismet.url = "string.example.com"
      Rakismet.url.should eql("string.example.com")
    end

    it "should allow url to be a proc" do
      Rakismet.url = Proc.new { "proc.example.com" }
      Rakismet.url.should eql("proc.example.com")
    end
  end

  describe ".validate_config" do
    it "should raise an error if key is not found" do
      Rakismet.key = ''
      lambda { Rakismet.send(:validate_config) }.should raise_error(Rakismet::Undefined)
    end

    it "should raise an error if host is not found" do
      Rakismet.host = ''
      lambda { Rakismet.send(:validate_config) }.should raise_error(Rakismet::Undefined)
    end
  end

  describe ".validate_key" do
    it "should use proxy host and port" do
      Rakismet.proxy_host = 'proxy_host'
      Rakismet.proxy_port = 'proxy_port'

      Net::HTTP.should_receive(:start).with(Rakismet.host, use_ssl: true, p_addr: 'proxy_host', p_port: 'proxy_port')
        .and_return(mock_response('valid'))

      Rakismet.validate_key
    end

    it "should set @@valid_key = true if key is valid" do
      Net::HTTP.stub(:start).and_return(mock_response('valid'))
      Rakismet.validate_key
      Rakismet.valid_key?.should be_truthy
    end

    it "should set @@valid_key = false if key is invalid" do
      Net::HTTP.stub(:start).and_return(mock_response('invalid'))
      Rakismet.validate_key
      Rakismet.valid_key?.should be_falsey
    end

    it "should build url with host" do
      host = "api.antispam.typepad.com"
      Rakismet.host = host
      Net::HTTP.should_receive(:start).with(host, use_ssl: true, p_addr: nil, p_port: nil).and_yield(http)
      Rakismet.validate_key
    end
  end

  describe '.excluded_headers' do
    it "should default to ['HTTP_COOKIE']" do
      Rakismet.excluded_headers.should eq ['HTTP_COOKIE']
    end
  end

  describe ".akismet_call" do
    before do
      Net::HTTP.stub(:start).and_yield(http)
    end

    it "should use proxy host and port" do
      Rakismet.proxy_host = 'proxy_host'
      Rakismet.proxy_port = 'proxy_port'

      Net::HTTP.should_receive(:start).with(@test_url, use_ssl: true, p_addr: 'proxy_host', p_port: 'proxy_port')
        .and_return(mock_response('valid'))

      Rakismet.send(:akismet_call, 'bogus-function')
    end

    it "should build url with API key for the correct host" do
      host = 'api.antispam.typepad.com'
      Rakismet.host = host
      Net::HTTP.should_receive(:start).with("#{Rakismet.key}.#{host}", use_ssl: true, p_addr: nil, p_port: nil)
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
      Rakismet.send(:akismet_call, 'bogus-function').should eql('akismet response')
    end

    it "should build query string when params are nil" do
      lambda {
        Rakismet.send(:akismet_call, 'bogus-function', { :nil_param => nil })
      }.should_not raise_error
    end
  end

end
