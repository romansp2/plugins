module RAWIMTOIViewWatchersInContextMenuStart
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_context_menu_start(context = {})
      #call_hook(:view_issues_context_menu_start, {:issues => @issues, :can => @can, :back => @back })
      projects = context[:issues].map(&:project).uniq
      allowed = projects.all?{ |project| User.current.allowed_to?(:add_watchers_in_more_than_one_issue, project)}
      if allowed
        context[:controller].send(:render_to_string, {partial: '/context_menu_watchers/watchers_link_to_context_menu', locals: context})
      end
    end
  end
end