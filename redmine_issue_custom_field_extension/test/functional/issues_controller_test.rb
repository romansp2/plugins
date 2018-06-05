# Redmine - project management software
# Copyright (C) 2006-2013  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < ActionController::TestCase
  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:roles, :member_roles, :members, :custom_fields, :custom_fields_trackers])
  fixtures :projects,
           :users,
           :members,
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
           :custom_values,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :repositories,
           :changesets
  
  include Redmine::I18n

  def setup
    #custom_field id = 12
    #custom_field type user 
    #custom_field name "Project 1 cf extension"

    ActionMailer::Base.smtp_settings = { 
        :address              => 'smtp.gmail.com',
        :port                 => 587,
        :domain               => 'gmail.com',
        :user_name            => 'alekseykond1@gmail.com',
        :password             => 'za3kl7mpeh',
        :authentication       => 'plain',
        :enable_starttls_auto => true
    }

    @custom_field_extension = IssueCustomFieldExtension.create! :custom_field_id     => 12,
                                                               :extends              => true, 
                                                               :notify               => true, 
                                                               :add_as_watcher       => true, 
                                                               :default_value_author => true, 
                                                               :visible              => true

    
    User.current = nil
  end

  def test_should_not_visible_issue
    #custom field type is user
    #custom_field id = 12
    #custom_field type user 
    #custom_field name "Project 1 cf extension"
    user = User.find_by_id 7
    project = Project.find_by_id(1)
    project.is_public = false
    project.save!

    issue = Issue.create! :author_id => 1, :project_id => project.id, :tracker_id => 3, :subject => "Test Custom Field"

    

    issue.custom_field_values= {"12" => ''}
    issue.save!

    @request.session[:user_id] = user.id
    get :show, :id => issue.id
  
    assert_response 403
  end

  def test_should_visible_issue
    #custom field type is user
    user = User.find_by_id 7
    project = Project.find_by_id(1)
    project.is_public = false
    project.save!

   
    issue = Issue.create! :author_id => 1, :project_id => project.id, :tracker_id => 3, :subject => "Test Custom Field", :custom_field_values => {"12" => "#{user.id}"}
    issue.custom_values.new(value: 7, custom_field_id: 12).save!

    @request.session[:user_id] = user.id

    get :show, :id => issue.id
  
    assert_response 200
  end

  def test_should_visible_issue_becose_from_group
    #custom field type is user
    user = User.find_by_id 7
    project = Project.find_by_id(1)
    project.is_public = false
    project.save!

    group = Group.new(:lastname => "Test Group Extend CF")
    group.users << User.find_by_id(7)
    group.save!

    member = Member.create!(:role_ids => [6], :user_id => group.id, :project_id => project.id)

    issue = Issue.create! :author_id => 1, :project_id => project.id, :tracker_id => 3, :subject => "Test Custom Field"
    issue.custom_values.new(value: group.id, custom_field_id: 12).save!
    
    @request.session[:user_id] = user.id

    get :show, :id => issue.id
  
    assert_response 200
  end

  def test_should_visible_issue_in_list_of_issues_becose_from_group
    #custom field type is user
    user = User.find_by_id 7
    project = Project.find_by_id(1)
    project.is_public = false
    project.save!

    group = Group.new(:lastname => "Test Group Extend CF")
    group.users << User.find_by_id(7)
    group.save!

    member = Member.create!(:role_ids => [6], :user_id => group.id, :project_id => project.id)

    issue = Issue.create! :author_id => 1, :project_id => project.id, :tracker_id => 3, :subject => "Test Custom Field"
    issue.custom_values.new(value: group.id, custom_field_id: 12).save!
        
    @request.session[:user_id] = user.id

    get :index, :project_id => project.id
  
    assert_select "a[href=/issues/#{issue.id}]"
  
    assert_response 200
  end

  def test_should_visible_issue_in_list_of_issues
    #custom field type is user
    user = User.find_by_id 7
    project = Project.find_by_id(1)
    project.is_public = false
    project.save!

    
    issue = Issue.create! :author_id => 1, :project_id => project.id, :tracker_id => 3, :subject => "Test Custom Field"
    issue.custom_values.new(value: user.id, custom_field_id: 12).save!
        
    @request.session[:user_id] = user.id

    get :index, :project_id => project.id
  
    assert_select "a[href=/issues/#{issue.id}]"
  end

  def test_should_not_visible_issue_in_list_of_issues
    #custom field type is user
    user = User.find_by_id 7
    project = Project.find_by_id(1)
    project.is_public = false
    project.save!

    issue = Issue.create! :author_id => 1, :project_id => project.id, :tracker_id => 3, :subject => "Test Custom Field"
    issue.custom_values.new(value: "", custom_field_id: 12).save!
        
    @request.session[:user_id] = user.id

    get :index, :project_id => project.id
  
    assert_select "a[href=/issues/#{issue.id}]", 0
  end

  def test_should_not_extend_custom_field
    #custom field type is user
    user = User.find_by_id 7
    project = Project.find_by_id(1)
    project.is_public = false
    project.save!

    @custom_field_extension.extends = false 
    @custom_field_extension.add_as_watcher = false 
    @custom_field_extension.save!

    issue = Issue.create! :author_id => 1, :project_id => project.id, :tracker_id => 3, :subject => "Test Custom Field"
    issue.custom_values.new(value: user.id, custom_field_id: 12).save!

    @request.session[:user_id] = user.id

    get :show, :id => issue.id
  
    assert_response 403
  end

  def test_should_notify_user_from_custom_field
    #custom field type is user
    user = User.find_by_id 1
    project = Project.find_by_id(1)
    project.is_public = false
    project.save!

    issue = Issue.create! :author_id => 1, :project_id => project.id, :tracker_id => 1, :tracker_id => 1, :subject => "Test Custom Field"
    issue.custom_values.new(value: 7, custom_field_id: 12).save!

    
    @request.session[:user_id] = user.id
    ActionMailer::Base.deliveries.clear
    assert_difference 'Journal.count' do
      put :update, :id => issue.id, :issue => {
                                         :custom_field_values => { "12" => "7" }
                                        }
    end
    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    assert [mail.bcc, mail.cc].flatten.include?(User.find(7).mail)
    
  end

  def test_should_notify_user_from_custom_field_about_new_issue
    #custom field type is user
    user = User.find_by_id 1
    project = Project.find_by_id(1)
    project.is_public = false
    project.save!

    #issue = Issue.create! :author_id => 1, :project_id => project.id, :tracker_id => 1, :tracker_id => 1, :subject => "Test Custom Field"
    #issue.custom_values.new(value: 7, custom_field_id: 12).save!

    
    @request.session[:user_id] = user.id

    ActionMailer::Base.deliveries.clear
    
    assert_difference 'Issue.count' do
      post :create, :project_id => 1,
                 :issue => {:tracker_id => 1,
                            :status_id => 1,
                            :subject => 'This is the test_new issue',
                            :description => 'This is the description',
                            :priority_id => 5,
                            :start_date => '2010-11-07',
                            :estimated_hours => '',
                            :custom_field_values => { "12" => "7" }}
    end

    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    assert [mail.bcc, mail.cc].flatten.include?(User.find(7).mail)
    
  end
  
end
