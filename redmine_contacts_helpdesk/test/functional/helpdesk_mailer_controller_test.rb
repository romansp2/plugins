require File.expand_path('../../test_helper', __FILE__)

# Re-raise errors caught by the controller.
# class HelpdeskMailerController; def rescue_action(e) raise e end; end

class HelpdeskMailerControllerTest < ActionController::TestCase
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

  RedmineHelpdesk::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts_helpdesk).directory + '/test/fixtures/', [:journal_messages])

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/helpdesk_mailer'

  def setup
    RedmineHelpdesk::TestCase.prepare

    @controller = HelpdeskMailerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_should_create_issue
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'

    post :index, :key => 'secret', :issue => {:project_id => 'ecookbook', :status => 'Closed', :tracker => 'Bug', :assigned_to => 'jsmith'}, :email => IO.read(File.join(FIXTURES_PATH, 'new_issue_new_contact.eml'))
    assert_response 201
    assert_not_nil Contact.find_by_first_name('New')
  end

  def test_should_create_issue_from_mailhandler
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'

    post :index, :key => 'secret', :issue => {:project => 'ecookbook', :status => 'Closed', :tracker => 'Bug', :priority => 'low'}, :email => IO.read(File.join(FIXTURES_PATH, 'new_issue_new_contact.eml'))
    assert_response 201
    assert_not_nil Contact.find_by_first_name('New')
  end

  def test_should_use_project_helpdesk_settings_for_issue
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'
    # Project settings
    ContactsSetting[:helpdesk_answer_from, Project.find('ecookbook').id] = 'test@email.from'
    ContactsSetting[:helpdesk_send_notification, Project.find('ecookbook').id] = 1
    ContactsSetting[:helpdesk_assigned_to, Project.find('ecookbook').id] = 2
    ContactsSetting[:helpdesk_issue_due_date,Project.find('ecookbook').id] = Date.today + 5
    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 1

    post :index, :key => 'secret', :issue => { :project => 'ecookbook' }, :email => IO.read(File.join(FIXTURES_PATH, 'new_issue_new_contact.eml'))
    assert_response 201

    issue = Issue.last
    assert_equal 'Normal', issue.priority.name
    assert_equal Date.today + 5, issue.due_date
    assert_equal User.find(2).login, issue.assigned_to.login
    contact = issue.customer
    assert_equal "New", contact.first_name
  end

  def test_should_get_mail
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'

    post :get_mail, :key => 'secret'
    assert_response :ok
  end

  def test_should_change_state_for_ticket_on_reply
    project = Project.find_by_identifier('ecookbook')
    issue = Issue.find(5)

    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'
    ContactsSetting[:helpdesk_reopen_status, project.id] = IssueStatus.where(:name => 'Feedback').first.id

    assert_not_equal 'Feedback', issue.status.name
    post :index, :key => 'secret', :issue => { :project => 'ecookbook' }, :email => IO.read(File.join(FIXTURES_PATH, 'reply_from_contact.eml'))

    issue.reload
    assert_equal 'Feedback', issue.status.name
  end

end
