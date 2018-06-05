module RedmineHelpdesk
  module Hooks
    class ViewIssuesHook < Redmine::Hook::ViewListener
      render_on :view_issues_edit_notes_bottom, :partial => 'issues/send_response'
      def view_issues_sidebar_issues_bottom(context = {})
        context[:controller].send(:render_to_string, { :partial => 'issues/helpdesk_reports', :locals => context }) +
          context[:controller].send(:render_to_string, { :partial => 'issues/helpdesk_customer_profile', :locals => context })
      end
      render_on :view_issues_show_details_bottom, :partial => 'issues/ticket_data'
      render_on :view_issues_form_details_top, :partial => 'issues/ticket_data_form'
    end
  end
end
