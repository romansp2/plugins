require File.expand_path('../../test_helper', __FILE__)

# Re-raise errors caught by the controller.
# class HelpdeskMailerController; def rescue_action(e) raise e end; end

class ContactsControllerTest < ActionController::TestCase
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

  RedmineHelpdesk::TestCase.create_fixtures(
    Redmine::Plugin.find(:redmine_contacts).directory + '/test/fixtures/',
    [
      :contacts,
      :contacts_projects,
      :contacts_issues,
      :deals,
      :notes,
      :tags,
      :taggings,
      :queries
    ]
  )

  RedmineHelpdesk::TestCase.create_fixtures(
    Redmine::Plugin.find(:redmine_contacts_helpdesk).directory + '/test/fixtures/',
    [ :journal_messages, :helpdesk_tickets]
  )

  include RedmineHelpdesk::TestHelper

  def setup
    RedmineHelpdesk::TestCase.prepare
    ActionMailer::Base.deliveries.clear

    @controller = ContactsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_contacts_with_closed_tickets
    @request.session[:user_id] = 1
    get 'index', "f"=>["open_tickets", ""], "op"=>{"open_tickets"=>"="},
      "v"=>{"open_tickets"=>["0"]}
    assert_response :success
    assert !assigns(:contacts).include?(Contact.find(1))
  end

  def test_contacts_with_open_tickets
    @request.session[:user_id] = 1
    get 'index', "f"=>["open_tickets", ""], "op" => { "open_tickets" => "=" },
      "v" => { "open_tickets"=>["1"] }
    assert_response :success
    assert assigns(:contacts).include?(Contact.find(1))
  end

  def test_contacts_with_number_of_tickets
    @request.session[:user_id] = 1
    get 'index', "f"=>["number_of_tickets", ""], "op"=>{ "number_of_tickets" => "=" },
      "v"=>{ "number_of_tickets"=>["1"] }
    assert_response :success
    assigns(:contacts).each do |contact|
      assert contact.helpdesk_tickets.count == 1
    end
  end      
end
