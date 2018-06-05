class ViewsIssuesHook < Redmine::Hook::ViewListener     
  def view_issues_new_top(context={ })
    context[:controller].send(:render_to_string, {:partial => "copy_issue_add_copy_attacments_hook/view_issues_new_top", :locals => context})
  end
end
# call_hook(:view_issues_new_top, {:issue => @issue})
