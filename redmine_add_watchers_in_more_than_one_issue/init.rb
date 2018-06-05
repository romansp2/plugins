ActionDispatch::Callbacks.to_prepare do
  require_dependency 'rawimtoi_view_watchers_in_context_menu_start'
  require_dependency 'rawimtoi_view_issues_bulk_edit_details_bottom'
  #require_dependency 'rawimtoi_add_method_to_issue_model'
  #Issue.send(:include, RAWIMTOIAddMethodToIssueModel)
 
end
Redmine::Plugin.register :redmine_add_watchers_in_more_than_one_issue do
  name 'Redmine Add Watchers In More Than One Issue plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_add_watchers_in_more_than_one_issue'
  author_url 'http://example.com/about'


  #Redmine::AccessControl.permission(:edit_issues).actions << "context_menu_watchers/new"
  #Redmine::AccessControl.permission(:edit_issues).actions << "context_menu_watchers/autocomplete_for_user"
  #Redmine::AccessControl.permission(:edit_issues).actions << "context_menu_watchers/create"
  #Redmine::AccessControl.permission(:delete_issue_watchers).actions << "context_menu_watchers/destroy"
  Redmine::AccessControl.map do |map|
    map.project_module :issue_tracking do |map|
      map.permission :add_watchers_in_more_than_one_issue, { :context_menu_watchers => [:new, :append, :autocomplete_for_user, :create] }
      map.permission :delete_watchers_in_more_than_one_issue, { :context_menu_watchers => [:destroy] }
    end
  end

  #permission :add_watchers_in_more_than_one_issue, { :context_menu_watchers => [:new, :append, :autocomplete_for_user, :create] }
  #permission :delete_watchers_in_more_than_one_issue, { :context_menu_watchers => [:destroy] }
  
end
