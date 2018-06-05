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

class OperationsControllerTest < ActionController::TestCase
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

  def setup
    Setting.plugin_redmine_finance["finance_operations_approval"] = 0
    Project.find(1).enable_module!(:finance)
  end

  def test_should_get_index
    @request.session[:user_id] = 1
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:operations)
    assert_nil assigns(:project)
  end

  def test_should_get_show
    @request.session[:user_id] = 1
    get :show, :id => 1
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:operation)
    assert_not_nil assigns(:project)
  end

  def test_should_get_new
    @request.session[:user_id] = 1
    get :new, :project_id => 1
    assert_response :success
    assert_template :new
    assert_not_nil assigns(:operation)
    assert_not_nil assigns(:project)
  end

  def test_should_get_edit
    @request.session[:user_id] = 1
    get :edit, :id => 1
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:operation)
    assert_not_nil assigns(:project)
  end

  def test_should_put_update
    @request.session[:user_id] = 1
    put :update, :id => 1, :operation => {:amount => 99.9}
    assert_response :redirect
    assert_equal 99.9, Operation.find(1).amount.to_f
  end

  def test_destroy
    @request.session[:user_id] = 1
    delete :destroy, :id => 1
    assert_redirected_to '/projects/ecookbook/operations'
    assert_nil Operation.find_by_id(1)
  end

  def test_should_post_create
    @request.session[:user_id] = 1
    assert_difference 'Operation.count' do
      post :create, :project_id => 1, :operation => {:description => "New operation description",
          :account_id => 1,
          :amount => 1000,
          :category_id => 1,
          :operation_date => Time.now}
      assert_response :redirect
    end
    assert_equal 1030, Operation.last.account.amount
    assert_equal "New operation description", Operation.last.description
  end
  def test_should_post_create_approved
    @request.session[:user_id] = 1
    post :create, :project_id => 1, :operation => {:description => "New approved operation description",
        :account_id => 1,
        :amount => 1234,
        :category_id => 1,
        :operation_date => Time.now,
        :is_approved => true}
    assert_response :redirect
    assert Operation.order(:id).last.is_approved?
  end

  def test_should_get_index_as_csv
    field = OperationCustomField.create!(:name => 'Test custom field', :is_filter => true, :field_format => 'string')
    operation = Operation.find(1)
    operation.custom_field_values = {field.id => "This is custom значение"}
    operation.save

    @request.session[:user_id] = 1
    get :index, :format => 'csv'
    assert_response :success
    assert_not_nil assigns(:operations)
    assert_equal "text/csv; header=present", @response.content_type
    assert @response.body.starts_with?("#,")
  end

  def test_get_index_calendar
    @request.session[:user_id] = 1

    get :index, :operations_list_style => 'crm_calendars/crm_calendar'
    assert_response :success
    assert_template :partial => '_crm_calendar'
    assert_not_nil assigns(:operations)
    assert_nil assigns(:project)
    assert_select 'td.even div.operation a', /120/
  end

  def test_get_index_with_approvals
    @request.session[:user_id] = 1
    Setting.plugin_redmine_finance["finance_operations_approval"] = 1
    get :index, :project_id => 'ecookbook'
    assert_response :success
    assert_select '.accounts-stat tr.disapproved.expense' do
      assert_select 'th a', :text => 'Disapproved expense'
      assert_select 'td.sum', /20\.0/
    end
  end

  def test_xhr_get_context_menu
    @request.session[:user_id] = 1
    Setting.plugin_redmine_finance["finance_operations_approval"] = 1
    xhr :get, :context_menu, :ids => ["3", "4"]
    assert_response :success
    assert_match /(Approve|Disapprove)/, @response.body
  end

  def test_post_bulk_update
    @request.session[:user_id] = 1
    Setting.plugin_redmine_finance["finance_operations_approval"] = 1
    post :bulk_update, :ids => ["2", "4"], :operation=> { :is_approved => false}
    assert Operation.find(2, 4).map(&:is_approved).all?
  end

  def test_should_filter_operation_by_currency
    @request.session[:user_id] = 1
    get :index, :set_filter => 1, :object_type => 'operation', :f => ['currency'], :op => { 'currency' => '=' }, :v => { 'currency' => ['EUR'] }
    assert_response :success
    assert_template :index
    assert_equal Account.where(:currency => 'EUR').first.operations, assigns(:operations)
    assert_nil assigns(:project)
  end

end
