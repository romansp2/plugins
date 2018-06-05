module RedmineIssueMailer
  module RedmineHook
    class Hooks < Redmine::Hook::ViewListener
      def view_issues_show_details_bottom(context = {})
      	if context[:issue].project.enabled_module_names.include?("issue_mailer")
          context[:controller].send(:render_to_string, {:partial => "redmine_issue_mailer_hooks/view_issues_show_details_bottom", :locals => context})
        end
      end
    end
  end
#call_hook(:view_issues_show_details_bottom, :issue => @issue)
end