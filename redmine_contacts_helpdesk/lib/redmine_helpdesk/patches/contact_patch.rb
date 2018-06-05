module RedmineHelpdesk
  module Patches
    module ContactPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :journals, :through => :journal_messages
          has_many :journal_messages, :dependent => :destroy

          has_many :tickets, :through => :helpdesk_tickets, :source => :issue #class_name => "Issue", :as  => :issue, :foreign_key => 'issue_id'
          has_many :helpdesk_tickets, :dependent => :destroy
        end
      end

      module InstanceMethods
        def mail
          self.primary_email
        end

        def all_tickets
          if self.is_company
            Issue.eager_load(:customer).where(:contacts => {:id => [self.id] | self.company_contacts.map(&:id) })
          else
            self.tickets
          end
        end

        def find_assigned_user(project, current_assigned)
          return User.find_by_id(current_assigned) unless RedmineHelpdesk.settings[:helpdesk_assign_contact_user].to_i > 0
          return assigned_to if assigned_to.present? && Project.visible(assigned_to).pluck(:id).include?(project.id)
          return contact_company.assigned_to if contact_company.present? && contact_company.assigned_to.present? &&
                                                Project.visible(contact_company.assigned_to).pluck(:id).include?(project.id)
          current_assigned
        end
      end
    end
  end
end

unless Contact.included_modules.include?(RedmineHelpdesk::Patches::ContactPatch)
  Contact.send(:include, RedmineHelpdesk::Patches::ContactPatch)
end
