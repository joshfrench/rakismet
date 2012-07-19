module Rakismet
  module Model

    def self.included(base)
      base.class_eval do
        attr_accessor :akismet_response
        class << self; attr_accessor :akismet_attrs; end
        extend ClassMethods
        include InstanceMethods
        self.rakismet_attrs
      end
    end

    module ClassMethods
      def rakismet_attrs(args={})
        self.akismet_attrs ||= {}
        [:comment_type, :author, :author_url, :author_email, :content, :user_role].each do |field|
          # clunky, but throwing around +type+ will break your heart
          fieldname = field.to_s =~ %r(^comment_) ? field : "comment_#{field}".intern
          self.akismet_attrs[fieldname] = args.delete(field) || field
        end
        [:user_ip, :user_agent, :referrer].each do |field|
          self.akismet_attrs[field] = args.delete(field) || field
        end
        args.each_pair do |f,v|
          self.akismet_attrs[f] = v
        end
      end

      def inherited(subclass)
        super
        subclass.rakismet_attrs akismet_attrs.dup
      end
    end

    module InstanceMethods
      def spam?
        if instance_variable_defined? :@_spam
          @_spam
        else
          data = akismet_data
          self.akismet_response = Rakismet.akismet_call('comment-check', data)
          @_spam = self.akismet_response == 'true'
        end
      end

      def spam!
        Rakismet.akismet_call('submit-spam', akismet_data)
        @_spam = true
      end

      def ham!
        Rakismet.akismet_call('submit-ham', akismet_data)
        @_spam = false
      end

      private

        def akismet_data
          akismet = self.class.akismet_attrs.keys.inject({}) do |data,attr|
            mapped_field = self.class.akismet_attrs[attr]
            data.merge attr =>  if mapped_field.is_a?(Proc)
                                  instance_eval(&mapped_field)
                                elsif !mapped_field.nil? && respond_to?(mapped_field)
                                  send(mapped_field)
                                elsif not [:comment_type, :author, :author_email,
                                        :author_url, :content, :user_role,
                                        :user_ip, :referrer,
                                        :user_agent].include?(mapped_field)
                                  # we've excluded any fields that appear to
                                  # have their default unmapped values
                                  mapped_field
                                elsif respond_to?(attr)
                                  send(attr)
                                elsif Rakismet.request.respond_to?(attr)
                                  Rakismet.request.send(attr)
                                end
          end
          akismet.delete_if { |k,v| v.nil? || v.empty? }
          akismet[:comment_type] ||= 'comment'
          akismet
        end
    end

  end
end
