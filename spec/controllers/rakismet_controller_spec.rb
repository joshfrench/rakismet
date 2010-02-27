require File.dirname(__FILE__) + '/../spec_helper'

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

class StubController < ActionController::Base
  include Rakismet::Controller
  def one ; render :nothing => true; end
  def two ; render :nothing => true; end
end

describe StubController do

  it "should set Rakismet::Base.rakismet_binding" do
    Rakismet::Base.should_receive(:rakismet_binding=).with(an_instance_of(Binding)).ordered
    Rakismet::Base.should_receive(:rakismet_binding=).with(nil).ordered
    get :one
  end

  it "should add around_filter" do
    StubController.filter_chain.map(&:method).should include(:rakismet)
  end
end

describe StubController.subclass('OnlyActions') { rakismet_filter(:only => :one) } do

  it "should add around filter to specified actions" do
    Rakismet::Base.should_receive(:rakismet_binding=).twice
    get :one
  end

  it "should not add around filter to unspecified actions" do
    Rakismet::Base.should_not_receive(:rakismet_binding=)
    get :two
  end
end

describe StubController.subclass('ExceptActions') { rakismet_filter(:except => :one) } do

  it "should not add around filter to specified actions" do
    Rakismet::Base.should_not_receive(:rakismet_binding=)
    get :one
  end
  
  it "should add around filter to other actions" do
    Rakismet::Base.should_receive(:rakismet_binding=).twice
    get :two
  end
end
