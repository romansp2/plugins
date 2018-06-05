require File.expand_path('../../test_helper', __FILE__)

class HelpdeskReportsControllerTest < ActionController::TestCase

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
    RedmineHelpdesk::TestCase.prepare

    @controller = HelpdeskReportsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_show_first_response_time_report
    @request.session[:user_id] = 1
    get :show, :project_id => 'ecookbook', :report => 'first_response_time',
                                           :set_filter => '1',
                                           :f => ['created_on', ''],
                                           :op => { 'created_on' => 'y' }
    assert_response :success
    assert_select '#content h2', /First response time/
    assert_select '.chart_table .header .column_data', 8
    assert_select '.column_data .percents', 2
    assert_select 'tr.metrics td p', /Average first response time/
    assert_select 'tr.metrics td p', /Average closing ticket time/
    assert_select 'tr.metrics td p', /Average count of responses to close/
    assert_select 'tr.metrics td p', /Total replies/
  end

  def test_show_productivity_report_with_no_data
    @request.session[:user_id] = 1
    get :show, :project_id => 'ecookbook', :report => 'first_response_time',
                                           :set_filter => '1',
                                           :f => ['created_on', ''],
                                           :op => { 'created_on' => 't' }
    assert_response :success
    assert_select '#content h2', /First response time/
    assert_select 'p.nodata', /No data to display/
  end

  def test_show_busiest_time_of_day_report
    @request.session[:user_id] = 1
    get :show, :project_id => 'ecookbook', :report => 'busiest_time_of_day',
                                           :set_filter => '1',
                                           :f => ['created_on', ''],
                                           :op => { 'created_on' => 'y' }
    assert_response :success
    assert_select '#content h2', /Busiest time of day/
    assert_select '.chart_table .header .column_data', 8
    assert_select '.column_data .percents', 1
    assert_select 'tr.metrics td p', /New tickets/
    assert_select 'tr.metrics td p', /New contacts/
  end

  def test_show_busiest_time_of_day_report_with_no_data
    @request.session[:user_id] = 1
    get :show, :project_id => 'ecookbook', :report => 'busiest_time_of_day',
                                           :set_filter => '1',
                                           :f => ['created_on', ''],
                                           :op => { 'created_on' => 'ld' }
    assert_response :success
    assert_select '#content h2', /Busiest time of day/
    assert_select 'p.nodata', /No data to display/
  end

end
