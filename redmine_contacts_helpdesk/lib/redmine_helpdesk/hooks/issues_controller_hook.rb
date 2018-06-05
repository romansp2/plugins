module RedmineHelpdesk
  module Hooks
    class IssuesControllerHook < Redmine::Hook::ViewListener
      def controller_issues_new_before_save(context = {})
        ticket = context[:issue].helpdesk_ticket
        return if ticket.nil? || ticket.from_address.present? || ticket.customer.nil? || ticket.customer.primary_email.blank?
        ticket.from_address = ticket.customer.primary_email
      end
    end
  end
end
