module RedmineIssueMailer
  module RedminePatch
    module ProjectsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
        base.class_eval do 
       	  unloadable # Send unloadable so it will not be unloaded in development
          include IssueMailSettingsHelper
          helper :issue_mail_settings

        end
      end
      

      module InstanceMethods
      end

      module ClassMethods
      end
    end

  end
end