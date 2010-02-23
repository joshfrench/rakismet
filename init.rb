ActionController::Base.send :include, Rakismet::Controller
ActiveRecord::Base.send :include, Rakismet::Model