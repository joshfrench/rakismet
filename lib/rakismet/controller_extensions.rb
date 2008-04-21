module Rakismet
  module ControllerExtensions
    
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end
    
    module ClassMethods
      def has_rakismet
        self.around_filter do |controller,action|
          Rakismet::Base.rakismet_binding = action.send(:binding)
          action.call
          Rakismet::Base.rakismet_binding = nil
        end
      end
    end
    
  end
end