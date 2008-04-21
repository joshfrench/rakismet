require File.dirname(__FILE__) + '/../spec_helper'

describe "Rakismet" do
  it "should extend ActiveRecord::Base" do
    ActiveRecord::Base.included_modules.should include(Rakismet::ModelExtensions)
  end
  
  it "should extend ActionController::Base" do
    ActionController::Base.included_modules.should include(Rakismet::ControllerExtensions)
  end
  
end