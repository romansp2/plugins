module RAWIMTOIViewIssuesBulkEditDetailsBottom
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_bulk_edit_details_bottom(context = {})
      #call_hook(:view_issues_bulk_edit_details_bottom, { :issues => @issues })
      projects = context[:issues].map(&:project).uniq
      allowed = projects.all?{ |project| User.current.allowed_to?(:add_watchers_in_more_than_one_issue, project)}
      allow_delete = projects.all?{ |project| User.current.allowed_to?(:delete_watchers_in_more_than_one_issue, project)}
      context[:allow_delete] = allow_delete
      if allowed
        context[:controller].send(:render_to_string, {partial: '/context_menu_watchers/watchers_link_to_issues_bulk_edit_details_bottom', locals: context})
      end
    end
  end
end