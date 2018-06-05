ActionDispatch::Callbacks.to_prepare do
  #require_dependency 'redmine_change_author_of_issue/view_layouts_base_html_head_patch'
  require_dependency 'redmine_change_author_of_issue/view_issues_sidebar'
  
  require_dependency 'redmine_change_author_of_issue/issues_helper_patch'
  IssuesHelper.send(:include, ChangeAuthorOfIssue::IssuesHelperPatch)

end
Redmine::Plugin.register :redmine_change_author_of_issue do
  name 'Redmine Change Author Of Issue plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_change_author_of_issue.git'
  author_url 'https://gitlab.qazz.pw/a.kondratenko/'

  Redmine::AccessControl.map do |map|
    map.project_module :issue_tracking do |map|
      map.permission :change_author_of_issue, { :change_author_of_issue => [:update, :edit] }
    end
  end
end
