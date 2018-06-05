module IssueBlockPatch
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_sidebar_planning_bottom(context = {})
      if !context[:project].nil? && context[:controller].action_name == "show" && User.current.allowed_to?(:edit_issues, context[:project]) && User.current.allowed_to?(:issue_block, context[:project])
        context[:controller].send(:render_to_string, {partial: '/issue_block/sidebar'})
      end
    end    
  end
end
