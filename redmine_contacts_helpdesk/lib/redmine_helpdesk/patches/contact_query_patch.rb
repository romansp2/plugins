require_dependency 'query'

module RedmineHelpdesk
  module Patches
    module ContactQueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:include, HelpdeskHelper)

        base.class_eval do
          unloadable

          alias_method_chain :available_filters, :helpdesk
        end
      end

      module InstanceMethods
        def sql_for_number_of_tickets_field(_, operator, value)
          "(#{Contact.table_name}.id IN (SELECT #{HelpdeskTicket.table_name}.contact_id
              FROM #{HelpdeskTicket.table_name}
              GROUP BY #{HelpdeskTicket.table_name}.contact_id
              HAVING count(#{HelpdeskTicket.table_name}.contact_id) #{operator} #{value.first}))"
        end

        def sql_for_open_tickets_field(_, operator, value)
          value = value.first
          in_cond = if (operator == '!' && value == '0') || (operator == '=' && value == '1')
                      'IN'
                    else
                      'NOT IN'
                    end
          "(#{Contact.table_name}.id #{in_cond} (SELECT #{HelpdeskTicket.table_name}.contact_id
            FROM #{HelpdeskTicket.table_name}
            INNER JOIN #{Issue.table_name} on #{Issue.table_name}.id = #{HelpdeskTicket.table_name}.issue_id
            INNER JOIN #{IssueStatus.table_name} ON #{IssueStatus.table_name}.id = #{Issue.table_name}.status_id
            WHERE (#{IssueStatus.table_name}.is_closed = #{ActiveRecord::Base.connection.quoted_false})
            ))"
        end

        def available_filters_with_helpdesk
          if @available_filters.blank? && User.current.allowed_to?(:view_helpdesk_tickets, project, :global => true)
            available_filters_without_helpdesk.merge!({ 'number_of_tickets' => {
              :type => :integer,
              :name => l(:label_helpdesk_number_of_tickets)
            } }) unless available_filters_without_helpdesk.key?('number_of_tickets')

            available_filters_without_helpdesk.merge!({ 'open_tickets' => {
              :name => l(:label_helpdesk_open_tickets),
              :type => :list, :values => [[l(:general_text_yes), '1'], [l(:general_text_no), '0']]
            } }) unless available_filters_without_helpdesk.key?('open_tickets')
          else
            available_filters_without_helpdesk
          end
          @available_filters
        end
      end
    end
  end
end

unless ContactQuery.included_modules.include?(RedmineHelpdesk::Patches::ContactQueryPatch)
  ContactQuery.send(:include, RedmineHelpdesk::Patches::ContactQueryPatch)
end
