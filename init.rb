# When using reloadable plugins (for engines), rakismet breaks. 
# This adds rakismet to the load_once path in development mode so that it doesn't break.

if RAILS_ENV == "development"
  RAILS_DEFAULT_LOGGER.info("[Rakismet] Adding rakismet to load once path")
  ActiveSupport::Dependencies.load_once_paths << File.join(RAILS_ROOT, "vendor/plugins/rakismet/lib")
end

ActionController::Base.send :include, Rakismet::ControllerExtensions
ActiveRecord::Base.send :include, Rakismet::ModelExtensions