ActionDispatch::Callbacks.to_prepare do
  require_dependency 'issue_block/view_issues_sidebar'
  require_dependency 'issue_block/view_issues_index_bottom_patch'
  #IssuesHelper.send(:include, ChangeAuthorOfIssue::IssuesHelperPatch)

  require_dependency 'issue_block/issue_patch'
  Issue.send(:include, Redmine::IssueBlock::IssuePatch)
  
  require_dependency 'issue_block/issues_controller_patch'
  IssuesController.send(:include, Redmine::IssueBlock::IssuesControllerPatch)

  require_dependency 'issue_block/journals_controller_patch'
  JournalsController.send(:include, Redmine::IssueBlock::JournalsControllerPatch)

  require_dependency 'issue_block/timelog_controller_patch'
  TimelogController.send :include, Redmine::IssueBlock::TimelogControllerPatch

  require_dependency 'issue_block/watchers_controller_patch'
  WatchersController.send :include, Redmine::IssueBlock::WatchersControllerPatch

  if Redmine::Plugin.installed?(:redmine_watcher_groups)
    require_dependency 'issue_block/watcher_groups_controller_patch'
    WatcherGroupsController.send :include, Redmine::IssueBlock::WatcherGroupsControllerPatch
  end

  if Redmine::Plugin.installed?(:redmine_add_watchers_in_more_than_one_issue)
    require_dependency 'issue_block/context_menu_watchers_controller_patch'
    ContextMenuWatchersController.send :include, Redmine::IssueBlock::ContextMenuWatchersControllerPatch
  end

  if Redmine::Plugin.installed?(:redmine_watcher_groups_in_more_than_one_issue)
    require_dependency 'issue_block/context_menu_watcher_groups_controller_patch'
    ContextMenuWatcherGroupsController.send :include, Redmine::IssueBlock::ContextMenuWatcherGroupsControllerPatch
  end

  if Redmine::Plugin.installed?(:redmine_contacts)
    require_dependency 'issue_block/contacts_issues_controller_patch'
    ContactsIssuesController.send :include, Redmine::IssueBlock::ContactsIssuesControllerPatch
  end

  if Redmine::Plugin.installed?(:redmine_change_author_of_issue)
    require_dependency 'issue_block/change_author_of_issue_controller_patch'
    ChangeAuthorOfIssueController.send :include, Redmine::IssueBlock::ChangeAuthorOfIssueControllerPatch
  end
end
Redmine::Plugin.register :redmine_issue_block do
  name 'Redmine Issue Block plugin'
  author 'Alexey Kondratenko'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://gitlab.qazz.pw/a.kondratenko/redmine_issue_block.git'
  author_url 'https://gitlab.qazz.pw/a.kondratenko/'


  Redmine::AccessControl.map do |map|
    map.project_module :issue_tracking do |map|
      map.permission :issue_block, { :issue_block => [:edit, :update] }
    end
  end
end
