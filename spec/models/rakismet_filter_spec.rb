require File.dirname(__FILE__) + '/../spec_helper'

describe Rakismet::Base do
  it "should set Rakismet::Base.current_request" do
    request = mock('request')
    controller = mock(:request => request)
    Rakismet::Base.should_receive(:current_request=).with(request).ordered
    Rakismet::Base.should_receive(:current_request=).with(nil).ordered
    Rakismet::Filter.filter(controller, &lambda{})
  end
end