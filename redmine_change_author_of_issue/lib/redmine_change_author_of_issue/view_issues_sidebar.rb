module IssuesFormDetailsBottomPatch
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_sidebar_planning_bottom(context = {})
      if !context[:project].nil? && context[:controller].action_name == "show" && User.current.allowed_to?(:edit_issues, context[:project]) && User.current.allowed_to?(:change_author_of_issue, context[:project])
        context[:controller].send(:render_to_string, {partial: '/change_author_of_issue/sidebar'})
      end
    end    
  end
end
