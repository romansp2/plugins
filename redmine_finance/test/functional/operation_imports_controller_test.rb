# encoding: utf-8
#
# This file is a part of Redmine Finance (redmine_finance) plugin,
# simple accounting plugin for Redmine
#
# Copyright (C) 2011-2016 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_finance is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_finance is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_finance.  If not, see <http://www.gnu.org/licenses/>.


require File.expand_path('../../test_helper', __FILE__)

class OperationImportsControllerTest < ActionController::TestCase
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

  RedmineFinance::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts).directory + '/test/fixtures/', [:contacts,
                                                                                                                   :contacts_projects,
                                                                                                                   :contacts_issues,
                                                                                                                   :deals,
                                                                                                                   :notes,
                                                                                                                   :tags,
                                                                                                                   :taggings,
                                                                                                                   :queries])
  if RedmineFinance.invoices_plugin_installed?
    RedmineFinance::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts_invoices).directory + '/test/fixtures/', [:invoices,
                                                                                                                              :invoice_lines])
  end

  RedmineFinance::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_finance).directory + '/test/fixtures/', [:accounts,
                                                                                                                  :operations,
                                                                                                                  :operation_categories])

  def fixture_files_path
    "#{File.expand_path('../..',__FILE__)}/fixtures/files/"
  end

  def setup
    Setting.plugin_redmine_finance["finance_operations_approval"] = 0
    Project.find(1).enable_module!(:finance)

    @controller = OperationImportsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @csv_file = Rack::Test::UploadedFile.new(fixture_files_path + "operations.csv", 'text/comma-separated-values')
  end

  test 'should open invoice import form' do
    @request.session[:user_id] = 1
    get :new, :project_id => 1
    assert_response :success
    if Redmine::VERSION.to_s >= '3.2'
      assert_select 'form input#file'
    else
      assert_select 'form#import_form'
    end
  end

  test 'should create new import object' do
    if Redmine::VERSION.to_s >= '3.2'
      @request.session[:user_id] = 1
      get :create, :project_id => 1,
                   :file => @csv_file
      assert_response :redirect
      assert_equal Import.last.class, OperationKernelImport
      assert_equal Import.last.user, User.find(1)
      assert_equal Import.last.project, 1
      assert_equal Import.last.settings, { 'project' => 1,
                                           'separator' => ',',
                                           'wrapper' => "\"",
                                           'encoding' => 'ISO-8859-1',
                                           'date_format' => '%m/%d/%Y' }
    end
  end

  test 'should open settings page' do
    if Redmine::VERSION.to_s >= '3.2'
      @request.session[:user_id] = 1
      import = OperationKernelImport.new
      import.user = User.find(1)
      import.project = Project.find(1)
      import.file = @csv_file
      import.save!
      get :settings, :id => import.filename, :project_id => 1
      assert_response :success
      assert_select 'form#import-form'
    end
  end

  test 'should show mapping page' do
    if Redmine::VERSION.to_s >= '3.2'
      @request.session[:user_id] = 1
      import = OperationKernelImport.new
      import.user = User.find(1)
      import.settings = { 'project' => 1,
                          'separator' => ',',
                          'wrapper' => "\"",
                          'encoding' => 'UTF-8',
                          'date_format' => '%m/%d/%Y' }
      import.file = @csv_file
      import.save!
      get :mapping, :id => import.filename, :project_id => 1
      assert_response :success
      if Redmine::VERSION.to_s >= '3.3'
        assert_select '#import_mapping_income'
        assert_select '#import_mapping_expense'
      else
        assert_select '#import_settings_mapping_income'
        assert_select '#import_settings_mapping_expense'
      end
      assert_select 'table.sample-data tr'
      assert_select 'table.sample-data tr td', 'Refund'
      assert_select 'table.sample-data tr td', 'Bank account'
    end
  end

  test 'should successfully import from CSV with new import' do
    if Redmine::VERSION.to_s >= '3.2'
      @request.session[:user_id] = 1
      import = OperationKernelImport.new
      import.user = User.find(1)
      import.settings = { 'project' => 1,
                          'separator' => ',',
                          'wrapper' => "\"",
                          'encoding' => 'UTF-8',
                          'date_format' => '%m/%d/%Y' }
      import.file = @csv_file
      import.save!
      post :mapping, :id => import.filename, :project_id => 1, :import_settings => { :mapping => { :income => 2, :expense => 3, :category => 4, :account => 5, :operation_date => 1 } }
      assert_response :redirect
      post :run, :id => import.filename, :project_id => 1, :format => :js
      assert_equal Operation.last.account.name, 'Bank account'
      assert_equal Operation.last.category.name, 'Category 1'
    end
  end
end
