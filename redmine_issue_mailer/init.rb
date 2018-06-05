ActionDispatch::Callbacks.to_prepare do
  #add tab to project settings
  ProjectsHelper.send(:include, RedmineIssueMailer::RedminePatch::ProjectsHelperPatch)

  #add relationship to project model
  Project.send :include, RedmineIssueMailer::RedminePatch::ProjectPatch
  Issue.send :include, RedmineIssueMailer::RedminePatch::IssuePatch
  Journal.send :include, RedmineIssueMailer::RedminePatch::JournalPatch
  MailHandlerController.send :include, RedmineIssueMailer::RedminePatch::MailHandlerControllerPatch
  #require_dependency 'redmine_issue_mailer/redmine_patch/mail_handler'
  MailHandler.send :include, RedmineIssueMailer::RedminePatch::MailHandlerPatch

  ApplicationController.send :include, RedmineIssueMailer::RedminePatch::ApplicationControllerPatch

  ProjectsController.send :include, RedmineIssueMailer::RedminePatch::ProjectsControllerPatch

  #hooks
  require_dependency 'redmine_issue_mailer/redmine_hook/controller_issues_edit_after_save'
  require_dependency 'redmine_issue_mailer/redmine_hook/controller_issues_edit_before_save'
  require_dependency 'redmine_issue_mailer/redmine_hook/view_issues_show_details_bottom'
  
  #macros
  require_dependency 'redmine_issue_mailer/redmine_macros/view_information_about_letter'

end

Redmine::Plugin.register :redmine_issue_mailer do
  name 'Redmine Issue Mailer plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.2.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_issue_mailer.git'
  author_url 'https://gitlab.qazz.pw/a.kondratenko'



  project_module :issue_mailer do
    permission :issue_mail_server_settings, { :issue_mail_server_settings => [:index, :show, :new, :create, :edit, :update, :destroy] }
    
    permission :issue_mail_settings,     {:issue_mail_settings => [:index] }
    
    permission :write_letter_to_clients, {:write_letter_to_clients => [:new]}
    #
    permission :write_letter_to_client, {}
    permission :write_letter_to_email_from_book_of_e_mail_address , {}
    permission :write_letter_without_restriction , {}
    #

    permission :issue_sent_on_client_emails,             {:issue_sent_on_client_emails => [:index, :show],
                                                          :undelivered_messages => [:index, :show]}
    permission :see_information_about_letter_from_issue, {:issue_sent_on_client_emails => [:show_from_issue],
                                                          :undelivered_messages => [:show_from_issue]}

    permission :issue_email_footers, {:issue_email_footers => [:index, :show, :new, :create, :edit, :update, :destroy]}
    permission :issue_email_footer_issues, {:issue_email_footer_issues => [:index, :show, :new, :create, :edit, :update, :destroy]}
    


    permission :issue_email_from_clients,          {:issue_email_from_clients => [:index, :show]}
    permission :show_email_from_client_from_issue, {:issue_email_from_clients => [:show_from_issue]}

    permission :issue_mailer_standard_fields, {:issue_mailer_standard_fields => [:index, :show, :new, :create, :edit, :update, :destroy]}
   
    permission :issue_mailer_custom_fields, {:issue_mailer_custom_fields => [:index, :show, :new, :create, :edit, :update, :destroy]}
    
    permission :edit_email_books, {:email_books => [:index, :show, :new, :create, :edit, :update, :destroy]}
  

  end

  settings :default => {'empty' => true}, :partial => 'settings/issue_mailer/settings'

end
 