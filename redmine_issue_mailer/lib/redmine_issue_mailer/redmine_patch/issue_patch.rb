module RedmineIssueMailer
  module RedminePatch
    module IssuePatch
      def self.included(base) # :nodoc:
      	base.extend(ClassMethods)
       	base.send(:include, InstanceMethods)
       	  # Same as typing in the class
       	base.class_eval do
       	  unloadable # Send unloadable so it will not be unloaded in development
          has_many :issue_sent_on_client_emails
          has_many :issue_email_from_clients

          
          has_one :issue_email_footer_issue, :dependent => :destroy
          #has_many_belongs_to_many :issue_email_footer, :limit=>1, :class => "IssueEmailFooterIssue"
          has_one :issue_email_footer, through: :issue_email_footer_issue


       	end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end