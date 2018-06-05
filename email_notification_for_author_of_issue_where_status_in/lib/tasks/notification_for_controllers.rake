namespace :redmine do
  namespace :email_notification_for_author do
    task :of_issue_where_status_in => :environment do
      Rails.logger.info 'Starting task "redmine:email_notification_for_author:of_issue_where_status_in" from plugin named "email_notification_for_author_of_issue_where_status_in"'
      Mailer.with_synched_deliveries do
        EmailNotificationForAuthor.of_issue_where_status_in
      end
    end
  end
end

