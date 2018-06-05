ActionDispatch::Callbacks.to_prepare do
  #require_dependency "add_project_search_field_hook/view_issues_edit_notes_bottom_hook"
  #require_dependency "add_project_search_field_hook/view_issues_bulk_edit_details_bottom_hook"
  require_dependency "add_project_search_field_hook/view_layout_project_search_field_hook"
end

Redmine::Plugin.register :redmine_add_project_search_field do
  name 'Redmine Add Project Search Field plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.0.4'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_add_project_search_field.git'
  author_url 'http://example.com/about'

  settings :default => {'empty' => true}, :partial => 'settings/redmine_add_project_search_field/settings'
end
