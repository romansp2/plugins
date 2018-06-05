# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)
# require 'helpdesk_controller'


class HelpdeskControllerTest < ActionController::TestCase
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

  FIXTURES_PATH = Redmine::Plugin.find(:redmine_contacts_helpdesk).directory + '/test/fixtures/helpdesk_mailer'

  def setup
    RedmineHelpdesk::TestCase.prepare

    @controller = HelpdeskController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def credentials(user, password=nil)
    ActionController::HttpAuthentication::Basic.encode_credentials(user, password || user)
  end

  def test_show_original
    @request.session[:user_id] = 1
    Setting.default_language = 'en'

    a = Attachment.create!(:container => HelpdeskTicket.find(1),
                       :file => uploaded_file("new_issue_new_contact_ru_2.eml", "message/rfc822"),
                       :author => User.find(1))

    get :show_original, :id => a, :project_id => 1
    assert_response :success
    assert_template 'attachments/file'
    assert_not_nil assigns(:content)
    assert_match 'Программа автоматически заменила категории', @response.body
  end

  def test_should_delete_spam
    @request.session[:user_id] = 1
    Setting.default_language = 'en'
    issue = Issue.new
    issue.copy_from(1).save
    contact = Contact.create(:first_name => "New contact", :project => Project.find('ecookbook'), :email => "mail@test.new")
    user = User.find(1)
    issue.helpdesk_ticket = HelpdeskTicket.new(:customer => contact,
                                              :issue => issue,
                                              :from_address => contact.primary_email,
                                              :ticket_date => Time.now)
    issue.save!

    assert_not_nil customer = issue.customer

    delete :delete_spam, :project_id => 1, :issue_id => issue.id
    assert_redirected_to :controller => 'issues', :action => 'index', :project_id => 'ecookbook'
    assert_nil Contact.find_by_id(contact.id)
    assert_nil Issue.find_by_id(issue.id)
    assert_match customer.primary_email, HelpdeskSettings[:helpdesk_blacklist, '1']
  end

  def test_should_save_settings
    @request.session[:user_id] = 1
    Setting.default_language = 'en'
    @project = Project.find('ecookbook')
    put :save_settings , :project_id => @project.id, :helpdesk_answer_from => 'test@test.ru', :helpdesk_lifetime => 60, :helpdesk_protocol => 'pop3', :helpdesk_host => 'pop3.test.ru'
    assert_response :redirect
    assert_equal('test@test.ru', ContactsSetting[:helpdesk_answer_from, @project.id])
    assert_equal('60', ContactsSetting[:helpdesk_lifetime, @project.id])
    assert_equal('pop3', ContactsSetting[:helpdesk_protocol, @project.id])
    assert_equal('pop3.test.ru', ContactsSetting[:helpdesk_host, @project.id])
  end

  def test_should_notify_sender_on_ticket_created_via_api
    user = User.find(1)
    user.pref[:no_self_notified] = false
    user.pref.save
    @request.session[:user_id] = 1
    @project = Project.find('ecookbook')
    Setting.default_language = 'en'
    Setting.rest_api_enabled = 1
    ContactsSetting[:helpdesk_answer_from, @project.id] = 'test@email.from'
    ContactsSetting[:helpdesk_send_notification, @project.id] = 1
    token = Token.create!(:user => User.find(1), :action => 'api', :value => 'topsecret')
    ActionMailer::Base.deliveries = []
    post :create_ticket,
         :format => :xml,
         :project_id => @project.id,
         :key => token.value,
         :ticket => {
           :issue => {
             :subject => 'test1',
             :tracker_id => Tracker.first.id
           },
           :contact => {
             :email      => 'test@example.com',
             :first_name => 'John'
           }
         }
    assert_response 201
    assert_equal(2, ActionMailer::Base.deliveries.count)
    assert_equal(['test@example.com'], ActionMailer::Base.deliveries.last.to)
  end

  private

  def uploaded_file(filename, mime)
    fixture_file_upload("../../plugins/redmine_contacts_helpdesk/test/fixtures/helpdesk_mailer/#{filename}", mime, true)
  end

end
