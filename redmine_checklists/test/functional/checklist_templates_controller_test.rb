# encoding: utf-8
#
# This file is a part of Redmine Checklists (redmine_checklists) plugin,
# issue checklists management plugin for Redmine
#
# Copyright (C) 2011-2016 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_checklists is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_checklists is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_checklists.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../test_helper', __FILE__)
class ChecklistTemplatesControllerTest < ActionController::TestCase
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
  RedmineChecklists::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_checklists).directory + '/test/fixtures/',
                                         [:checklists])

  def setup
    RedmineChecklists::TestCase.prepare
    Setting.default_language = 'en'
    Project.find(1).enable_module!(:checklists)
    Project.find(1).enable_module!(:issue_tracking)
    User.current = nil
    @second_user = User.find(2)
    @project_1 = Project.find(1)
    @issue_1 = Issue.find(1)
    @checklist_1 = Checklist.find(1)
    MemberRole.create(:member_id => 1, :role_id => 2)
  end

  test 'should show new form' do
    @request.session[:user_id] = 1
    get :new
    assert_select 'form.new_checklist_template div.box.tabular'
  end

  test 'creates new checklist template' do
    @request.session[:user_id] = 1
    post :create, :checklist_template => { :name => 'test1', :template_items => 'item1 item2' }, :checklist_template_is_for_all => true
    assert_equal 'test1', ChecklistTemplate.last.name
    assert_equal 1, ChecklistTemplate.last.user_id
  end

  test 'user with right can create template' do
    @request.session[:user_id] = @second_user.id
    post :create, :checklist_template => { :name => 'user_test', :template_items => 'item1 item2' }, :project_id => @project_1
    assert_equal 'user_test', ChecklistTemplate.last.name
    assert_equal 2, ChecklistTemplate.last.user_id
    assert_equal @project_1, ChecklistTemplate.last.project
  end

  test 'user cant create public template for all projects' do
    @request.session[:user_id] = @second_user.id
    post :create, :checklist_template => { :name => 'public_template', :template_items => 'item1 item2', :is_public => '1' },
                  :checklist_template_is_for_all => '1',
                  :project_id => @project_1
    assert_equal 'public_template', ChecklistTemplate.last.name
    assert_equal 2, ChecklistTemplate.last.user_id
    assert_equal true, ChecklistTemplate.last.is_public
    assert_equal @project_1, ChecklistTemplate.last.project
  end

  test 'nobody cant edit user template if it not public' do
    @request.session[:user_id] = @second_user.id
    post :create, :checklist_template => { :name => 'not_public_template', :template_items => 'item1 item2', :is_public => '0' },
                  :checklist_template_is_for_all => '1',
                  :project_id => @project_1
    assert_equal 'not_public_template', ChecklistTemplate.last.name
    @request.session[:user_id] = 1
    get :edit, :project_id => @project_1, :id => ChecklistTemplate.last.id
    assert_response :missing
  end

  test 'should show edit form' do
    @request.session[:user_id] = 1
    @template = ChecklistTemplate.create!(:name => 'template1', :template_items => 'item1 item2', :is_public => true)
    get :edit, :id => @template.to_param
    assert_select 'form.edit_checklist_template div.box.tabular'
  end

  test 'should update checklist template' do
    @request.session[:user_id] = 1
    @template = ChecklistTemplate.create!(:name => 'template1', :template_items => 'item1 item2', :is_public => true)
    put :update, :id => @template.to_param, :checklist_template => { :name => 'test2' }
    assert_equal 'test2', ChecklistTemplate.last.name
  end

  test 'should delete checklist template' do
    @request.session[:user_id] = 1
    @template = ChecklistTemplate.create!(:name => 'template1', :template_items => 'item1 item2', :is_public => true)
    delete :destroy, :id => @template.to_param
    assert_equal 0, ChecklistTemplate.count
  end
end
