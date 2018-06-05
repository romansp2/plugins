ActionDispatch::Callbacks.to_prepare do
  Rails.logger.info 'Starting Redmine Add Users List In Watcher Filter plugin'

  require_dependency 'add_users_list_in_watcher_filter_patch/issue_query_patch'
  IssueQuery.send(:include, Redmine::AddUsersListInWatcherFilterPatch::IssueQueryPatch)
end

Redmine::Plugin.register :redmine_add_users_list_in_watcher_filter do
  name 'Redmine Add Users List In Watcher Filter plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_add_users_list_in_watcher_filter.git'
  author_url 'http://example.com/about'
end
