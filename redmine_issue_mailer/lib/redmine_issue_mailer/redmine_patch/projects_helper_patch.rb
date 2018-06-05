require_dependency 'projects_helper'

module RedmineIssueMailer
  module RedminePatch
    module ProjectsHelperPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :project_settings_tabs, :redmine_issue_mailer
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def project_settings_tabs_with_redmine_issue_mailer
          tabs = project_settings_tabs_without_redmine_issue_mailer
          tabs.push({:name => 'issue_mail_settings', :action => :issue_mail_settings, :partial => 'issue_mail_settings/index', :label => :label_issue_mail_settings})
          tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
        end
      end
    end
  end
end