ActionDispatch::Callbacks.to_prepare do
 require_dependency 'hot_buttons_patch/add_tabs_to_project_settings' 
 ProjectsHelper.send(:include, HotButtonsPatch::AddTabsToProjectSettings)

 require_dependency 'hot_buttons_patch/project_patch'
 Project.send(:include, HotButtonsPatch::ProjectPatch)

 require_dependency 'hot_buttons_patch/role_patch'
 Role.send(:include, HotButtonsPatch::RolePatch)

 require_dependency 'hot_buttons_patch/view_issues_sidebar_issues_bottom_hook'

 require_dependency 'hot_buttons_patch/issues_controller_patch'
 IssuesController.send(:include, HotButtonsPatch::IssuesControllerPatch)
 
end
Redmine::Plugin.register :redmine_hot_buttons do
  name 'Redmine Hot Buttons plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '1.0.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_hot_buttons.git'
  author_url 'https://gitlab.qazz.pw/a.kondratenko'

  

  permission :edit_hot_buttons, {:hot_buttons => [:index, :new, :show, :edit, :update, :update_form, :create, :destroy]}
  #permission :use_hot_buttons, {:hot_button_issue => [:index, :set_issue_to]}, :require => :loggedin
  perm = Redmine::AccessControl.permissions.select{|perm| perm.name == :edit_issues}.first
  perm.actions << "issues/hot_button_update_form"

end
