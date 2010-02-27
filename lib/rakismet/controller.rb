module Rakismet
  module Controller
    
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        around_filter Rakismet::Filter
      end
    end

    module ClassMethods
      def rakismet_filter(opts={})
        skip_filter Rakismet::Filter # in case we're inheriting/overriding an existing Rakismet filter
        opts.assert_valid_keys(:only, :except)
        self.around_filter Rakismet::Filter, opts
      end
    end
    
  end
end