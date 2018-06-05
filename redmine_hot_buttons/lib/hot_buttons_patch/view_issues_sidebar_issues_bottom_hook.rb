module HotButtonsHook
  class ViewsIssuesHook < Redmine::Hook::ViewListener     
    def view_issues_sidebar_issues_bottom(context={ })
      if !context[:project].nil? && context[:controller].action_name == "show" && User.current.allowed_to?(:edit_issues, context[:project]) 
        context[:controller].send(:render_to_string, {:partial => "hot_buttons_sidebar/hot_buttons_sidebar", :locals => context})
      end
    end
  end
end   
# call_hook(:view_issues_sidebar_issues_bottom)
