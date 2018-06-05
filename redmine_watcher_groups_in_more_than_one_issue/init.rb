ActionDispatch::Callbacks.to_prepare do
  if Redmine::Plugin.installed?(:redmine_watcher_groups)
    require_dependency 'rwgimtoi_view_watcher_groups_in_context_menu_start'
    require_dependency 'rwgimtoi_view_issues_bulk_edit_details_bottom'
  else
  	Rails.logger.info 'Cannot Find "Watcher Groups plugin for Redmine" '
  end
end
Redmine::Plugin.register :redmine_watcher_groups_in_more_than_one_issue do
  name 'Redmine Watcher Groups In More Than One Issue plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_watcher_groups_in_more_than_one_issue'
  author_url 'https://gitlab.qazz.pw/a.kondratenko'

  #Redmine::AccessControl.permission(:edit_issues).actions << "context_menu_watcher_groups/new"
  #Redmine::AccessControl.permission(:edit_issues).actions << "context_menu_watcher_groups/autocomplete_for_group"
  #Redmine::AccessControl.permission(:edit_issues).actions << "context_menu_watcher_groups/create"
  #Redmine::AccessControl.permission(:delete_issue_watchers).actions << "context_menu_watcher_groups/destroy"

  Redmine::AccessControl.map do |map|
    map.project_module :issue_tracking do |map|
      map.permission :add_watcher_groups_in_more_than_one_issue, { :context_menu_watcher_groups => [:new, :append, :autocomplete_for_group, :create] }
      map.permission :delete_watcher_groups_in_more_than_one_issue, { :context_menu_watcher_groups => [:destroy] }
    end
  end
  #permission :add_watcher_groups_in_more_than_one_issue, { :context_menu_watcher_groups => [:new, :append, :autocomplete_for_group, :create] }
  #permission :delete_watcher_groups_in_more_than_one_issue, { :context_menu_watcher_groups => [:destroy] }
  

end
