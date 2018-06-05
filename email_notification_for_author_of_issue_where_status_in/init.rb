Redmine::Plugin.register :email_notification_for_author_of_issue_where_status_in do
  name 'plugin Email Notification for Author of Issue Where Status In'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/email_notification_for_author_of_issue_where_status_in'
  author_url 'https://gitlab.qazz.pw/a.kondratenko/'

  settings :default => {'empty' => true}, :partial => 'settings/email_notification_for_author_of_issue_where_status_in'
end
