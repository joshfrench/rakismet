require File.dirname(__FILE__) + '/../spec_helper'

Rakismet::TestingError = Class.new(StandardError)

describe Rakismet::Base do
  before do
    @request = mock('request')
    @controller = mock('controller', :request => @request)
  end

  it "should set Rakismet::Base.current_request" do
    Rakismet::Base.should_receive(:current_request=).with(@request).ordered
    Rakismet::Base.should_receive(:current_request=).with(nil).ordered
    Rakismet::Filter.filter(@controller, &lambda{})
  end

  it "should not retain the request object in case of error" do
    begin
      Rakismet::Filter.filter(@controller, &lambda{ raise Rakismet::TestingError })
    rescue Rakismet::TestingError
      Rakismet::Base.current_request.should be_nil
    end
  end
end