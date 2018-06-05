module IssueMailSettingsHelper
  def project_menu_settings(project, selected)
  	link_to( t(:issue_mail_settings , scope: [:redmine_issue_mailer]), issue_mail_settings_path(project_id: project.identifier), style: "#{'background-color: #A2C0DE;' if selected == issue_mail_settings_path}" ) + " | " +
    link_to( t(:issue_mail_server_settings , scope: [:redmine_issue_mailer]), issue_mail_server_settings_path(project_id: project.identifier), style: "#{'background-color: #A2C0DE;' if selected == issue_mail_server_settings_path}" ) + " | " +
    link_to( t(:list_of_letters, scope: [:redmine_issue_mailer]), issue_sent_on_client_emails_path(project_id: project.identifier), style: "#{'background-color: #A2C0DE;' if selected == issue_sent_on_client_emails_path}" ) + " | " +
    link_to( t(:list_of_letters_from_clients, scope: [:redmine_issue_mailer]), issue_email_from_clients_path(project_id: project.identifier), style: "#{'background-color: #A2C0DE;' if selected == issue_email_from_clients_path}" )  + " | " +
    link_to( t(:list_standard_fields, scope: [:redmine_issue_mailer]), issue_mailer_standard_fields_path(project_id: project.identifier), style: "#{'background-color: #A2C0DE;' if selected == issue_mailer_standard_fields_path}" ) + " | " +
    link_to( t(:list_custom_fields, scope: [:redmine_issue_mailer]), issue_mailer_custom_fields_path(project_id: project.identifier), style: "#{'background-color: #A2C0DE;' if selected == issue_mailer_custom_fields_path}" ) + " | " +
    link_to( t(:list_email_footers, scope: [:redmine_issue_mailer]), issue_email_footers_path(project_id: project.identifier), style: "#{'background-color: #A2C0DE;' if selected == issue_email_footers_path}" ) + " | " +
    link_to( t(:email_book, scope: [:redmine_issue_mailer]), email_books_path(project_id: project.identifier), style: "#{'background-color: #A2C0DE;' if selected == email_books_path}" )
  end
end
