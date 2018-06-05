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
class ChecklistTemplateCategoriesControllerTest < ActionController::TestCase
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
    @project_1 = Project.find(1)
    @issue_1 = Issue.find(1)
    @checklist_1 = Checklist.find(1)
  end


  test 'should show new form' do
    @request.session[:user_id] = 1
    get :new
    assert_select 'form.new_checklist_template_category div.box.tabular'
  end

  test 'creates new checklist template category' do
    @request.session[:user_id] = 1
    post :create, :checklist_template_category => { :name => 'test1' }
    assert_equal 1, ChecklistTemplateCategory.count
  end

  test 'should show edit form' do
    @request.session[:user_id] = 1
    @template = ChecklistTemplateCategory.create!(:name => 'category1')
    get :edit, :id => @template.to_param
    assert_select 'form.edit_checklist_template_category div.box.tabular'
  end

  test 'should update checklist template category' do
    @request.session[:user_id] = 1
    @template = ChecklistTemplateCategory.create!(:name => 'category1')
    put :update, :id => @template.to_param, :category => { :name => 'category2' }
    assert_equal 'category2', ChecklistTemplateCategory.last.name
  end

  test 'should delete checklist template' do
    @request.session[:user_id] = 1
    @template = ChecklistTemplateCategory.create!(:name => 'category1')
    delete :destroy, :id => @template.to_param
    assert_equal 0, ChecklistTemplateCategory.count
  end
end
