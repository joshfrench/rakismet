require File.dirname(__FILE__) + '/../spec_helper'

describe "Rakismet" do
  it "should extend ActiveRecord::Base" do
    ActiveRecord::Base.included_modules.should include(Rakismet::Model)
  end
  
  it "should extend ActionController::Base" do
    ActionController::Base.included_modules.should include(Rakismet::Controller)
  end
  
end