module RedmineIssueMailer
  module RedminePatch
    module JournalPatch
      def self.included(base) # :nodoc:
      	base.extend(ClassMethods)
       	base.send(:include, InstanceMethods)
       	  # Same as typing in the class
       	base.class_eval do
       	  unloadable # Send unloadable so it will not be unloaded in development
          has_one :issue_sent_on_client_email
          has_one :issue_email_from_client
       	end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end