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

class OperationsController < ApplicationController
  unloadable

  before_filter :find_operation, :only => [:show, :edit, :update, :destroy]
  before_filter :find_operation_project, :only => [:new, :create]
  before_filter :find_optional_project, :only => :index
  before_filter :bulk_find_operations, :only => [:bulk_update, :bulk_edit, :bulk_destroy, :context_menu]
  before_filter :authorize, :except => [:index, :auto_complete]
  before_filter :find_project_by_project_id, :only => :auto_complete

  accept_api_auth :index, :show, :create, :update, :destroy

  helper :contacts
  helper :watchers
  helper :custom_fields
  helper :timelog
  helper :operations
  helper :attachments
  helper :issues
  helper :context_menus
  helper :crm_queries
  helper :queries
  helper :sort
  helper :calendars
  include SortHelper
  include OperationsHelper
  include ContactsHelper
  include AttachmentsHelper
  include QueriesHelper
  include CrmQueriesHelper

  def index
    retrieve_crm_query('operation')
    sort_init(@query.sort_criteria.empty? ? [['operation_date', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    if @query.valid?
      case params[:format]
      when 'csv', 'pdf'
        @limit = Setting.issues_export_limit.to_i
      when 'xml', 'json'
        @offset, @limit = api_offset_and_limit
      else
        @limit = per_page_option
      end

      @operations_debit = @query.income_amount
      @operations_credit = @query.expense_amount

      @operations_count = @query.object_count
      @operations_scope = @query.objects_scope
      @operations_pages = Paginator.new @operations_count, @limit, params['page']
      @offset ||= @operations_pages.offset
      @operation_count_by_group = @query.object_count_by_group
      @operations = @query.results_scope(
        :include => [{:contact => [:avatar, :projects, :address]}, :author],
        :search => params[:search],
        :order => sort_clause,
        :limit  =>  @limit,
        :offset =>  @offset
      )
      @accounts = @project ? @project.accounts.visible : Account.visible
      @approved_amount_by_account = Operation.amount_by_account(true)

      if RedmineFinance.operations_approval?
        @disapproved_income = Operation.disapproved_amount(true, @project)
        @disapproved_expense = Operation.disapproved_amount(false, @project)
      end
      if operations_list_style == 'crm_calendars/crm_calendar'
        retrieve_crm_calendar(:start_date_field => "operation_date", :due_date_field => "operation_date")
        @calendar.events = @query.results_scope(
            :include => [:contact],
            :search => params[:search],
            :conditions => ["operation_date BETWEEN ? AND ?", @calendar.startdt, @calendar.enddt]
          )
      end

      respond_to do |format|
        format.html { render(:partial => operations_list_style, :layout => false) if request.xhr? }
        format.api
        format.csv { send_data(operations_to_csv(@operations), :type => 'text/csv; header=present', :filename => 'operations.csv') }
      end
    else
      respond_to do |format|
        format.html { render(:template => 'operations/index', :layout => !request.xhr?) }
        format.any(:atom, :csv, :pdf) { render(:nothing => true) }
        format.api { render_validation_errors(@query) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def new
    @operation = Operation.new
    @operation.account_id = params[:account_id]
    @operation.contact_id = params[:contact_id]
    @operation.operation_date = Time.now
    @operation.copy_from(params[:copy_from]) if params[:copy_from]
  end

  def create
    @operation = Operation.new
    @operation.account ||= @project.accounts.find((params[:operation] && params[:operation][:account_id]) || params[:account_id] || :first)
    @operation.safe_attributes = params[:operation]
    @operation.author = User.current
    update_operation_time

    if @operation.save
      attachments = Attachment.attach_files(@operation, (params[:attachments] || (params[:operation] && params[:operation][:uploads])))
      render_attachment_warning_if_needed(@operation)
      flash[:notice] = l(:notice_successful_create)

      respond_to do |format|
        format.html { redirect_to :action => "show", :id => @operation }
        format.api  { render :action => 'show', :status => :created, :location => operation_url(@operation, :project_id => @project) }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@operation) }
      end
    end
  end

  def update
    (render_403; return false) unless @operation.editable_by?(User.current)
    @operation.safe_attributes = params[:operation]
    update_operation_time
    if @operation.save
      attachments = Attachment.attach_files(@operation, (params[:attachments] || (params[:operation] && params[:operation][:uploads])))
      render_attachment_warning_if_needed(@operation)
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_back_or_default operation_path(@operation) }
        format.api  { head :ok }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit"}
        format.api  { render_validation_errors(@operation) }
      end
    end
  end

  def destroy
    (render_403; return false) unless @operation.destroyable_by?(User.current)
    if @operation.destroy
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = l(:notice_unsuccessful_save)
    end
    respond_to do |format|
      format.html { redirect_to :action => "index", :project_id => @operation.project }
      format.api  { head :ok }
    end

  end

  def context_menu
    @operation = @operations.first if (@operations.size == 1)
    @can = {:edit =>  @operations.collect{|c| c.editable_by?(User.current)}.all?,
            :approve => @operations.collect{|c| User.current.allowed_to?(:approve_operations, c.project)}.all?,
            :delete => @operations.collect{|c| c.destroyable_by?(User.current)}.all?
            }

    @back = back_url
    render :layout => false
  end

  def edit
  end

  def show
    @comments = @operation.comments.to_a
    @comments.reverse! if User.current.wants_comments_in_reverse_order?
    @operation_object = OperationObject.new if RedmineFinance.invoices_plugin_installed?
    @relations = @operation.relations.select {|r| r.other_operation(@operation) && r.other_operation(@operation).visible? }
    @relation = OperationRelation.new
    @invoices = @operation.invoices.visible if RedmineFinance.invoices_plugin_installed?
  end
  def bulk_update
    @operations = Operation.where(:id => params[:ids])
    raise ActiveRecord::RecordNotFound if @operations.empty?
    unsaved_operation_ids = []
    saved_operations_ids = []
    @operations.each do |operation|
      operation.reload
      operation.safe_attributes = parse_params_for_bulk_operation_attributes(params)
      if operation.save
        saved_operations_ids << operation.id
      else
        unsaved_operation_ids << operation.id
      end
    end

    @safe_attributes = @operations.map(&:safe_attribute_names).reduce(:&)

    set_flash_from_bulk_contact_save(@operations, unsaved_operation_ids)
    redirect_back_or_default(operations_path(:project_id => @project))
  end

  def bulk_destroy
    @operations.each do |operation|
      begin
        operation.reload.destroy
      rescue ::ActiveRecord::RecordNotFound # raised by #reload if issue no longer exists
        # nothing to do, issue was already deleted (eg. by a parent)
      end
    end
    respond_to do |format|
      format.html { redirect_back_or_default(:action => 'index', :project_id => @project) }
      format.api  { head :ok }
    end
  end

  def auto_complete
    @operations = []
    q = (params[:q] || params[:term]).to_s.strip
    scope = Operation.visible
    scope = scope.scoped.limit(params[:limit] || 10)
    scope = scope.live_search(q) unless q.blank?
    scope = scope.eager_load(:account).where(:accounts => {:project_id => @project}) if @project
    @operations = scope.sort!{|x, y| x.operation_date <=> y.operation_date }

    render :text => @operations.map{|operation| {
                                          'id' => operation.id,
                                          'label' => "#{operation.category.name} ##{operation.id} - #{format_date(operation.operation_date)}: (#{operation.amount_to_s})",
                                          'value' => operation.id
                                          }
                                 }.to_json
  end

  private

  def find_operation
    @operation = Operation.eager_load([{:account => :project}, :contact]).find(params[:id])
    raise Unauthorized unless @operation.visible?
    @project ||= @operation.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_operation_project
    project_id = params[:project_id] || (params[:operation] && params[:operation][:project_id])
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def bulk_find_operations
    @operations = Operation.eager_load({:account => :project}).where(:id => params[:id] || params[:ids])
    raise ActiveRecord::RecordNotFound if @operations.empty?
    if @operations.detect {|operation| !operation.visible?}
      deny_access
      return
    end
    @projects = @operations.collect(&:project).compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def parse_params_for_bulk_operation_attributes(params)
    attributes = (params[:operation] || {}).reject {|k,v| v.blank?}
    attributes.keys.each {|k| attributes[k] = '' if attributes[k] == 'none'}
    if custom = attributes[:custom_field_values]
      custom.reject! {|k,v| v.blank?}
      custom.keys.each do |k|
        if custom[k].is_a?(Array)
          custom[k] << '' if custom[k].delete('__none__')
        else
          custom[k] = '' if custom[k] == '__none__'
        end
      end
    end
    attributes
  end

  def update_operation_time
    if params[:operation_time] && params[:operation_time].to_s.gsub(/\s/, "").match(/^(\d{1,2}):(\d{1,2})$/)
      @operation.operation_date = @operation.operation_date.change({:hour => $1.to_i % 24, :min => $2.to_i % 60}) if @operation.operation_date.present?
    end
  end

end
