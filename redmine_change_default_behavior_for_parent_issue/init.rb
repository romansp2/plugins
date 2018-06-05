ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_change_default_behavior_for_parent_issue/issue_patch'
  Issue.send :include, Redmine::ChangeDefaultBehaviorForParentIssue::IssuePatch
end

Redmine::Plugin.register :redmine_change_default_behavior_for_parent_issue do
  name 'Redmine Change Default Behavior For Parent Issue plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_change_default_behavior_for_parent_issue.git'
  author_url 'https://gitlab.qazz.pw/a.kondratenko'
end
