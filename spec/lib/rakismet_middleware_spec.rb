require File.dirname(__FILE__) + '/../spec_helper'

describe Rakismet::Middleware do

  let(:env) { { 'REMOTE_IP' => '127.0.0.1', 'USER_AGENT' => 'RSpec', 'REFERER' => 'http://test.host/referrer' } }
  let(:app) { double(:app, :call => nil) }
  let(:request) { double(:request).as_null_object }

  before do
    @middleware = Rakismet::Middleware.new(app)
  end

  it "should set set Rakismet.request variables" do
    Rakismet.stub(:request).and_return(request)
    request.should_receive(:remote_ip=).with('127.0.0.1')
    request.should_receive(:user_agent=).with('RSpec')
    request.should_receive(:referer=).with('http://test.host/referrer')
    @middleware.call(env)
  end

  it "should clear Rakismet.request after request is complete" do
    @middleware.call(env)
    Rakismet.request.remote_ip.should be_nil
    Rakismet.request.user_agent.should be_nil
    Rakismet.request.referer.should be_nil
  end
end
