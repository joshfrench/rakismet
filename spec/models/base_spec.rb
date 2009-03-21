require File.dirname(__FILE__) + '/../spec_helper'

describe Rakismet::Base do

  before do
    load File.join(RAILS_ROOT, 'config', 'initializers', 'rakismet.rb')
  end

  describe ".validate_constants" do
    it "should raise an error if key is not found" do
      Rakismet::KEY = ""
      lambda { Rakismet::Base.send(:validate_constants) }.should raise_error(Rakismet::Undefined)
    end

    it "should raise an error if url is not found" do
      Rakismet::URL = ""
      lambda { Rakismet::Base.send(:validate_constants) }.should raise_error(Rakismet::Undefined)
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
  end
  
  describe ".akismet_call" do
    before do
      @http = mock(:http)
      Net::HTTP.stub!(:start).and_yield(@http)
    end
    
    it "should build url with API key" do
      Net::HTTP.should_receive(:start).with("#{Rakismet::KEY}.rest.akismet.com").and_yield(stub_everything(:http))
      Rakismet::Base.send(:akismet_call, 'bogus-function')
    end
    
    it "should post data to named function" do
      @http.should_receive(:post).with('/1.1/bogus-function', %r(foo=#{CGI.escape 'escape//this'}), Rakismet::HEADERS)
      Rakismet::Base.send(:akismet_call, 'bogus-function', { :foo => 'escape//this' })
    end
    
    it "should return response.body" do
      Net::HTTP.stub!(:start).and_return([nil, 'akismet response'])
      Rakismet::Base.send(:akismet_call, 'bogus-function').should eql('akismet response')
    end

    it "should build query string when params are nil" do
      lambda {
        Rakismet::Base.send(:akismet_call, 'bogus-function', { :nil_param => nil })
      }.should_not raise_error(NoMethodError)
    end
  end
  
end