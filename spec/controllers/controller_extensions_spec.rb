require File.dirname(__FILE__) + '/../spec_helper'

describe stub_controller = ActionController::Base.subclass('StubController') { has_rakismet; define_method(:index, proc{}) } do
  it "should set Rakismet::Base.rakismet_binding" do
    Rakismet::Base.should_receive(:rakismet_binding=).twice
    get :index
  end
  
  it "should return Rakismet::Base.rakismet_binding to nil after request" do
    get :index
    Rakismet::Base.rakismet_binding.should be_nil
  end
end