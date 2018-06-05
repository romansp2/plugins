module ContextMenuWatchersHelper
  def watcheds_addable_watcher_users(watcheds, project)
    users = project.users
    users.reject! {|user| !user.allowed_to?(:view_issues, project)}
    users
  end
end
