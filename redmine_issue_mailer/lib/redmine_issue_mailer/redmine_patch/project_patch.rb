module RedmineIssueMailer
  module RedminePatch
    module ProjectPatch
      def self.included(base) # :nodoc:
      	base.extend(ClassMethods)
       	base.send(:include, InstanceMethods)
       	  # Same as typing in the class
       	base.class_eval do
       	  unloadable # Send unloadable so it will not be unloaded in development
          has_many :issue_mail_server_settings
          has_many :issue_sent_on_client_emails
          has_many :issue_email_footers, :dependent => :destroy
          has_many :issue_email_from_clients
          has_one  :issue_mailer_standard_field
          has_one  :issue_mailer_custom_field_value

          has_many :email_books
       	end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end