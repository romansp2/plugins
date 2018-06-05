module RedmineHelpdesk
  module Hooks
    class ViewProjectsHook < Redmine::Hook::ViewListener
      def view_projects_show_sidebar_bottom(context = {})
        context[:controller].send(:render_to_string, { :partial => 'issues/helpdesk_reports', :locals => context }) +
          context[:controller].send(:render_to_string, { :partial => 'projects/helpdesk_tickets', :locals => context })
      end
    end
  end
end
