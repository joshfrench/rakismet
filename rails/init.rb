ActionController::Base.send :include, Rakismet::ControllerExtensions
ActiveRecord::Base.send :include, Rakismet::ModelExtensions