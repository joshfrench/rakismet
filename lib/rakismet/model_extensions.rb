module Rakismet
  module ModelExtensions
   
    def self.included(base)
      base.class_eval do
        attr_accessor :akismet_response
        class_inheritable_hash :akismet_attrs
        extend ClassMethods
        include InstanceMethods
      end
    end
   
    module ClassMethods
      def has_rakismet(args={})
        self.akismet_attrs ||= {}
        [:comment_type, :author, :author_url, :author_email, :content].each do |field|
           # clunky, but throwing around +type+ will break your heart
           fieldname = field.to_s =~ %r(^comment_) ? field : "comment_#{field}".intern
           self.akismet_attrs[fieldname] = args[field] || field
        end
        [:user_ip, :user_agent, :referrer].each do |field|
          self.akismet_attrs[field] = (args[field] || field) if args.has_key?(field) or self.public_instance_methods.include?(field.to_s)
        end
      end
    end
    
    module InstanceMethods
      def spam?
        raise Rakismet::NoBinding, "Couldn't find action.binding" if Rakismet::Base.rakismet_binding.nil?
        data = akismet_data
        { :referrer => 'request.referer', :user_ip => 'request.remote_ip',
          :user_agent => 'request.user_agent', }.each_pair do |k,v|
          data[k] = eval(v, Rakismet::Base.rakismet_binding)
        end
        self.akismet_response = Rakismet::Base.akismet_call('comment-check', data)
        self.akismet_response == 'true'
      end

      def spam!
        Rakismet::Base.akismet_call('submit-spam', akismet_data)
      end

      def ham!
        Rakismet::Base.akismet_call('submit-ham', akismet_data)
      end

      private

        def akismet_data
          self.class.akismet_attrs.keys.inject({}) do |data,attr|
            v = self.class.akismet_attrs[attr].is_a?(Proc) ? self.class.akismet_attrs[attr].bind(self).call : send(self.class.akismet_attrs[attr])
            data.merge attr => v
          end
        end
    end
    
  end
end