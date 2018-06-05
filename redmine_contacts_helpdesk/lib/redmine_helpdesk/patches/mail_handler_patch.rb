module RedmineHelpdesk
  module Patches
    module MailHandlerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :receive_issue_reply, :handle_helpdesk
          alias_method_chain :cleanup_body, :handle_helpdesk
          alias_method_chain :dispatch, :handle_helpdesk
        end
      end

      module InstanceMethods
        def receive_issue_reply_with_handle_helpdesk(issue_id, from_journal=nil)
          journal = receive_issue_reply_without_handle_helpdesk(issue_id, from_journal)
          helpdesk_receive_issue_reply(issue_id, journal, from_journal)
        end

        private

        def dispatch_with_handle_helpdesk
          if email_tag
            tag_issue = Issue.where(:id => email_tag[/\+(\d+)@/, 1].to_i).first
            return dispatch_without_handle_helpdesk unless tag_issue
            receive_issue_reply(tag_issue.id)
          else
            dispatch_without_handle_helpdesk
          end
        rescue MissingInformation => e
          logger.error "#{email && email.message_id}: missing information from #{user}: #{e.message}" if logger
          false
        rescue UnauthorizedAction => e
          logger.error "#{email && email.message_id}: unauthorized attempt from #{user}" if logger
          false
        rescue Exception => e
          # TODO: send a email to the user
          logger.error "#{email && email.message_id}: dispatch error #{e.message}" if logger
          false
        end

        def email_tag
          (email.to.present? && email.to.find { |email| email.match(/\+\d+@/) }) ||
            (email.cc.present? && email.cc.find { |email| email.match(/\+\d+@/) })
        end

        def helpdesk_receive_issue_reply(issue_id, journal, from_journal=nil)
          return unless journal
          return journal if journal.notes.blank?
          project = journal.issue.project
          return journal unless journal.user.allowed_to?(:send_response, journal.issue.project) && journal.issue.customer

          unless HelpdeskSettings[:send_note_by_default, project]
            regexp = /^@@sendmail@@\s*$/
            return journal unless journal.notes.match(regexp)
            journal.notes = journal.notes.gsub(regexp, '')
          end

          contact = journal.issue.customer

          begin
            HelpdeskMailer.with_activated_perform_deliveries do
              if msg = HelpdeskMailer.issue_response(contact, journal).deliver
                JournalMessage.create(:to_address => msg.to_addrs.first.to_s.slice(0, 255),
                                      :is_incoming => false,
                                      :message_date => Time.now,
                                      :message_id => msg.message_id.to_s.slice(0, 255),
                                      :source => HelpdeskTicket::HELPDESK_EMAIL_SOURCE,
                                      :cc_address => msg.cc.join(', ').to_s.slice(0, 255),
                                      :bcc_address => msg.bcc.join(', ').to_s.slice(0, 255),
                                      :contact => contact,
                                      :journal => journal)
                journal.issue.assigned_to = User.current unless journal.issue.assigned_to
                journal.issue.status_id = HelpdeskSettings[:helpdesk_new_status, journal.issue.project_id] unless HelpdeskSettings[:helpdesk_new_status, journal.issue.project_id].blank?
                journal.issue.save
                HelpdeskLogger.info  "#{msg.message_id}: Replay sent to #{contact.name} - [#{contact.emails.first}]" if HelpdeskLogger
              end
            end
          rescue Exception => e
            HelpdeskLogger.info  "Error of replay sending to #{contact.name} - [#{contact.emails.first}], #{e.message}" if HelpdeskLogger
          end

          journal.save!
          journal
        end

        def cleanup_body_with_handle_helpdesk(body)
          cleanup_body_without_handle_helpdesk(body).gsub('&#13;', '')
        end
      end

    end
  end
end

unless MailHandler.included_modules.include?(RedmineHelpdesk::Patches::MailHandlerPatch)
  MailHandler.send(:include, RedmineHelpdesk::Patches::MailHandlerPatch)
end
