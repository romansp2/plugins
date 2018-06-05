# Redmine - project management software
# Copyright (C) 2006-2014  Jean-Philippe Lang
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

class MailHandlerControllerTest < ActionController::TestCase
  fixtures :users, :email_addresses, :projects, :enabled_modules, :roles, :members, :member_roles, :issues, :issue_statuses,
           :trackers, :projects_trackers, :enumerations, :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/',
                            [:issue_mail_server_settings,
                             :issue_sent_on_client_emails,
                             :issue_mailer_standard_fields])

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/mail_handler'

  def setup
    User.current = nil

    ActionMailer::Base.smtp_settings = { 
        :address              => 'smtp.gmail.com',
        :port                 => 587,
        :domain               => 'gmail.com',
        :user_name            => 'alekseykond1@gmail.com',
        :password             => 'za3kl7mpeh',
        :authentication       => 'plain',
        :enable_starttls_auto => true
    }
  end

  def test_should_create_issue
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'

    #Exist settings Issue-Mailer module 
    assert_difference ['Issue.count', 'IssueEmailFromClient.count'] do
      post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'ticket_on_given_project.eml')),
                                     "allow_override"=>"project, status, tracker, category, priority, assigned_to",
                                     "unknown_user"=>"accept", 
                                     "default_group"=>nil,
                                     "no_account_notice"=>nil, 
                                     "no_notification"=>nil, 
                                     "no_permission_check"=>"1", 
                                     "issue"=>{"project"=>"", 
                                       "status"=>"", 
                                       "tracker"=>"", 
                                       "category"=>"", 
                                       "priority"=>""
                                     }
    end
    assert_response 201
  end

  def test_should_create_issue_with_custom_values
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'
    #field = IssueCustomField.create!(:name => 'Float', :is_for_all => true, :tracker_ids => [1], :field_format => 'float')
    #issue = Issue.generate!(:project_id => 2, :tracker_id => 1, :custom_field_values => {field.id => '185.6'})
    #Exist settings Issue-Mailer module
    project = Project.find 2
    issue_mailer_custom_field_value = project.build_issue_mailer_custom_field_value

    custom_field = CustomField.find_by_name "Searchable field"

    cf_user = IssueCustomField.create!(:name => 'Multi user', :field_format => 'user', :multiple => true, :is_for_all => true, :tracker_ids => [1,2,3])

    issue_mailer_custom_field_value.value = {"#{custom_field.id}" => "Hello", "#{cf_user.id}" =>  project.members.map(&:user_id)}
    issue_mailer_custom_field_value.save!


    assert_difference ['Issue.count', 'IssueEmailFromClient.count'] do
      post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'ticket_on_given_project.eml')),
                                     "allow_override"=>"project, status, tracker, category, priority, assigned_to",
                                     "unknown_user"=>"accept", 
                                     "default_group"=>nil,
                                     "no_account_notice"=>nil, 
                                     "no_notification"=>nil, 
                                     "no_permission_check"=>"1", 
                                     "issue"=>{"project"=>"", 
                                       "status"=>"", 
                                       "tracker"=>"", 
                                       "category"=>"", 
                                       "priority"=>""
                                     }
    end

    assert Issue.last.custom_field_values.find{|field| field.custom_field.name == "Searchable field"}.value == "Hello"

    assert Issue.last.custom_field_values.find{|field| field.custom_field.name == 'Multi user'}.value == [project.members.map{|member| "#{member.user_id}"}.first]
    assert_response 201
  end

  def test_should_assigned_issue_to
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'
    #field = IssueCustomField.create!(:name => 'Float', :is_for_all => true, :tracker_ids => [1], :field_format => 'float')
    #issue = Issue.generate!(:project_id => 2, :tracker_id => 1, :custom_field_values => {field.id => '185.6'})
    #Exist settings Issue-Mailer module
    assert_difference ['Issue.count', 'IssueEmailFromClient.count'] do
      post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'ticket_on_given_project.eml')),
                                     "allow_override"=>"project, status, tracker, category, priority, assigned_to",
                                     "unknown_user"=>"accept", 
                                     "default_group"=>nil,
                                     "no_account_notice"=>nil, 
                                     "no_notification"=>nil, 
                                     "no_permission_check"=>"1", 
                                     "issue"=>{"project"=>"", 
                                       "status"=>"", 
                                       "tracker"=>"", 
                                       "category"=>"", 
                                       "priority"=>""
                                     }
    end
    assert Issue.last.assigned_to_id == 2
    assert_response 201
  end

  def test_should_not_create_issue
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'
    
    #Not exist settings Issue-Mailer module
    assert_no_difference ['Issue.count', 'IssueEmailFromClient.count'] do
      post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'ticket_not_exist_mail_serv_sett_on_given_project.eml')),
                                     "allow_override"=>"project, status, tracker, category, priority, assigned_to",
                                     "unknown_user"=>"accept", 
                                     "default_group"=>nil,
                                     "no_account_notice"=>nil, 
                                     "no_notification"=>nil, 
                                     "no_permission_check"=>"1", 
                                     "issue"=>{"project"=>"", 
                                       "status"=>"", 
                                       "tracker"=>"", 
                                       "category"=>"", 
                                       "priority"=>""
                                     }
    end
    assert_response 422
  end

  def test_should_create_note_issue
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'

    #Exist settings Issue-Mailer module
    assert_difference ['Journal.count', 'IssueEmailFromClient.count'] do
      post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'ticket_on_given_issue.eml')),
                                     "allow_override"=>"project, status, tracker, category, priority, assigned_to",
                                     "unknown_user"=>"accept", 
                                     "default_group"=>nil,
                                     "no_account_notice"=>nil, 
                                     "no_notification"=>nil, 
                                     "no_permission_check"=>"1", 
                                     "issue"=>{"project"=>"", 
                                       "status"=>"", 
                                       "tracker"=>"", 
                                       "category"=>"", 
                                       "priority"=>""
                                     }
    end
    assert_response 201
  end

  def test_should_not_create_note_should_recognize_sent_yourself
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'

    
    #Exist settings Issue-Mailer module
    email = Mail.new(IO.read(File.join(FIXTURES_PATH, 'ticket_on_given_issue_to_and_from_are_equal.eml')))
    message_id = email.message_id
    issue = Issue.find 4

    sent_on_client = IssueSentOnClientEmail.new
    sent_on_client.project_id = issue.project_id
    sent_on_client.issue_id   = issue.id
    sent_on_client.message_id = message_id
    sent_on_client.to         = email.to
    sent_on_client.from       = email.from
    sent_on_client.deliver    = false
    sent_on_client.save!

    assert_no_difference ['Journal.count', 'IssueSentOnClientEmail.count'] do
      post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'ticket_on_given_issue_to_and_from_are_equal.eml')),
                                     "allow_override"=>"project, status, tracker, category, priority, assigned_to",
                                     "unknown_user"=>"accept", 
                                     "default_group"=>nil,
                                     "no_account_notice"=>nil, 
                                     "no_notification"=>nil, 
                                     "no_permission_check"=>"1", 
                                     "issue"=>{"project"=>"", 
                                       "status"=>"", 
                                       "tracker"=>"", 
                                       "category"=>"", 
                                       "priority"=>""
                                     }
    end

    assert sent_on_client.reload.deliver
    assert @request.params["email"].blank?

    #assert_response 422
  end

  def test_should_not_create_note_should_recognize_deliver
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'

    
    #Exist settings Issue-Mailer module
    message = Mail.new(IO.read(File.join(FIXTURES_PATH, 'mail_has_delivered.eml')))
    message_id = message.message_id
    issue = Issue.find 4

    sent_on_client = IssueSentOnClientEmail.new
    sent_on_client.project_id = issue.project_id
    sent_on_client.issue_id   = issue.id
    sent_on_client.from       = message.from.first
    sent_on_client.to         = message.to.first
    sent_on_client.message_id = message_id
    sent_on_client.deliver    = false
    sent_on_client.save!

    assert_no_difference 'Journal.count' do
      post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'mail_has_delivered.eml')),
                                     "allow_override"=>"project, status, tracker, category, priority, assigned_to",
                                     "unknown_user"=>"accept", 
                                     "default_group"=>nil,
                                     "no_account_notice"=>nil, 
                                     "no_notification"=>nil, 
                                     "no_permission_check"=>"1", 
                                     "issue"=>{"project"=>"", 
                                       "status"=>"", 
                                       "tracker"=>"", 
                                       "category"=>"", 
                                       "priority"=>""
                                     }
    end

    assert sent_on_client.reload.deliver
    assert @request.params["email"].blank?

    #assert_response 422
  end

  def test_should_recogmize_undelivered_message
    Setting.plugin_redmine_issue_mailer['mailer_daemon'] = "MAILER-DAEMON@mail.mouse.qazz.pw"
    Setting.plugin_redmine_issue_mailer["regexp_scan"] = 'corp.mail.ru=>/(.*@.*), mail.mouse.qazz.pw=>/<(.*@.*)>'

    assert_difference 'UndeliveredMessage.count', 3 do 
      post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'undelivered_message.eml')),
                                     "allow_override"=>"project, status, tracker, category, priority, assigned_to",
                                     "unknown_user"=>"accept", 
                                     "default_group"=>nil,
                                     "no_account_notice"=>nil, 
                                     "no_notification"=>nil, 
                                     "no_permission_check"=>"1", 
                                     "issue"=>{"project"=>"", 
                                       "status"=>"", 
                                       "tracker"=>"", 
                                       "category"=>"", 
                                       "priority"=>""
                                     }
    end

    assert_response 422

  end
end



