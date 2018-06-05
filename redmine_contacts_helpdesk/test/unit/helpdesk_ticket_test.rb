require File.expand_path('../../test_helper', __FILE__)
include RedmineHelpdesk::TestHelper

class HelpdeskTicketTest < ActiveSupport::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

  RedmineHelpdesk::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts).directory + '/test/fixtures/', [:contacts,
                                                                                                                    :contacts_projects,
                                                                                                                    :contacts_issues,
                                                                                                                    :deals,
                                                                                                                    :notes,
                                                                                                                    :tags,
                                                                                                                    :taggings,
                                                                                                                    :queries])

  RedmineHelpdesk::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts_helpdesk).directory + '/test/fixtures/', [:journal_messages,
                                                                                                                             :helpdesk_tickets])

  def setup
    Setting.default_language = 'en'
    RedmineHelpdesk::TestCase.prepare

    ActionMailer::Base.deliveries.clear
    Setting.host_name = 'mydomain.foo'
    Setting.protocol = 'http'
    Setting.plain_text_mail = '0'
  end

  def test_should_calculate_reaction_date_from_first_journal
    helpdesk_ticket = HelpdeskTicket.find(1)
    issue = helpdesk_ticket.issue
    journal_message = issue.journals.order(:created_on).last.build_journal_message(:contact => helpdesk_ticket.customer, :to_address => helpdesk_ticket.customer.primary_email)
    journal_message.save
    helpdesk_ticket.reload

    helpdesk_ticket.calculate_metrics
    assert_equal 2, issue.journals.count
    assert_equal helpdesk_ticket.reaction_time, issue.journals.order(:created_on).first.created_on - helpdesk_ticket.ticket_date.utc
  end

  def test_ticket_token
    helpdesk_ticket = HelpdeskTicket.find(1)
    first_user = User.find(1)
    second_user = User.find(2)
    second_user.pref['time_zone'] = 'Monterrey'

    User.current = first_user
    first_token = helpdesk_ticket.token
    User.current = second_user
    second_token = helpdesk_ticket.token

    assert_equal first_token, second_token
  end

  def test_should_change_default_destination_form_outgoing_email
    helpdesk_ticket = HelpdeskTicket.find(1)
    issue = helpdesk_ticket.issue
    other_contact = Contact.find(2)
    journal_message = issue.journals.order(:created_on).last.build_journal_message(:contact => other_contact,
                                                                                   :from_address => other_contact.primary_email,
                                                                                   :is_incoming => true,
                                                                                   :message_date => Time.now)
    journal_message.save
    helpdesk_ticket.reload

    assert_equal helpdesk_ticket.default_to_address, other_contact.primary_email

    journal_message = issue.journals.order(:created_on).last.build_journal_message(:contact => helpdesk_ticket.customer,
                                                                                   :from_address => helpdesk_ticket.customer.primary_email,
                                                                                   :is_incoming => true,
                                                                                   :message_date => Time.now)
    journal_message.save
    helpdesk_ticket.reload

    assert_equal helpdesk_ticket.default_to_address, helpdesk_ticket.customer.primary_email
  end

  def test_create_assigned_ticket
    user = User.find(2)
    contact = Contact.find(1)
    contact.assigned_to = user
    contact.save

    with_helpdesk_settings(:helpdesk_assign_contact_user => 1) do
      issue = submit_helpdesk_email('new_issue_to_contact.eml', :issue => { :project_id => 'onlinestore' })

      assert_not_nil issue
      assert_equal issue.is_private?, false
      assert_equal issue.assigned_to, user
    end
  end

  def test_create_private_assigned_ticket
    user = User.find(2)
    contact = Contact.find(1)
    contact.assigned_to = user
    contact.save

    with_helpdesk_settings(:helpdesk_assign_contact_user => 1, :helpdesk_create_private_tickets => 1) do
      issue = submit_helpdesk_email('new_issue_to_contact.eml', :issue => { :project_id => 'onlinestore' })

      assert_not_nil issue
      assert_equal issue.reload.is_private?, true
      assert_equal issue.reload.assigned_to, user
    end
  end

  def test_create_not_assigned_ticket_if_project_not_visible
    user = User.find(9)
    contact = Contact.find(2)
    contact.assigned_to = user
    contact.save

    with_helpdesk_settings(:helpdesk_assign_contact_user => 1, :helpdesk_create_private_tickets => 0) do
      issue = submit_helpdesk_email('new_issue_to_contact.eml', :issue => { :project_id => 'onlinestore' })

      assert_not_nil issue
      assert_equal issue.is_private?, false
      assert_equal issue.assigned_to, nil
    end
  end
end
