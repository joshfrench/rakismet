module Rakismet
  module ControllerExtensions
    
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end
    
    def rakismet(&block)
      Rakismet::Base.rakismet_binding = binding
      yield
      Rakismet::Base.rakismet_binding = nil
    end
    private :rakismet

    module ClassMethods
      def has_rakismet(opts={})
        skip_filter :rakismet # in case we're inheriting from another Rakismeted controller
        opts.assert_valid_keys(:only, :except)
        self.around_filter :rakismet, opts
      end
    end
    
  end
end