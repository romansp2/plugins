module RedmineIssueMailer
  module RedminePatch
    module CustomFieldPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods 
      
        base.class_eval do 
           unloadable
           has_many :issue_mailer_custom_field_values, :dependent => :delete_all
        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    
    end
  end
end
