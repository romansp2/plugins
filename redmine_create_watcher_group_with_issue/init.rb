ActionDispatch::Callbacks.to_prepare do
  
  if Redmine::Plugin.installed?(:redmine_watcher_groups)
  	Rails.logger.info 'Loading redmine_create_watcher_group_with_issue plugin'
    require_dependency 'create_watcher_group_with_issue_patch/view_issues_form_details_bottom_hook'
    require_dependency 'create_watcher_group_with_issue_patch/controller_issues_new_after_save_hook'
  else
  	Rails.logger.info 'Cannot Find "Watcher Groups plugin for Redmine" '
  end
end
Redmine::Plugin.register :redmine_create_watcher_group_with_issue do
  name 'Redmine Create Watcher Group With Issue plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_create_watcher_group_with_issue.git'
  author_url 'https://gitlab.qazz.pw/a.kondratenko'
end
