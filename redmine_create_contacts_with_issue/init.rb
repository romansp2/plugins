ActionDispatch::Callbacks.to_prepare do
  require_dependency 'ccwi_add_contacts_in_issue_form'  
  require_dependency 'ccwi_controller_issues_new_after_save'
end

Redmine::Plugin.register :redmine_create_contacts_with_issue do
  name 'Redmine Create Contacts With Issue plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_create_contacts_with_issue'
  author_url 'https://gitlab.qazz.pw/a.kondratenko'  
end
