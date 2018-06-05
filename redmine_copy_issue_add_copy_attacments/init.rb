ActionDispatch::Callbacks.to_prepare do
 require_dependency 'copy_issue_add_copy_attacments_hook' 
end

Redmine::Plugin.register :redmine_copy_issue_add_copy_attacments do
  name 'Redmine Copy Issue Add Copy Attacments plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_copy_issue_add_copy_attacments.git'
  author_url 'http://example.com/about'
end
