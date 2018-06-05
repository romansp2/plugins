class HelpdeskReportsController < ApplicationController
  unloadable
  menu_item :issues

  helper :helpdesk
  helper :queries
  include QueriesHelper

  before_filter :find_optional_project, :authorize_global

  def show
    retrieve_reports_query
    @collector = HelpdeskDataCollectorManager.new(@report).collect_data(@query)
    return render_404 unless @collector
    respond_to do |format|
      format.html
    end
  end

  private

  def retrieve_reports_query
    @report = params[:report] || 'first_response_time'
    report_query_class = @report == 'first_response_time' ? HelpdeskReportsFirstResponseQuery : HelpdeskReportsBusiestTimeQuery
    if params[:set_filter] || session[:helpdesk_reports_query].nil? || session[:helpdesk_reports_query][:project_id] != (@project ? @project.id : nil)
      @query = report_query_class.new(:name => '_', :project => @project)
      @query.build_from_params(params)
      @query[:filters] = { 'created_on' => { :operator => 'm', :values => [''] } } unless @query[:filters]
      session[:helpdesk_reports_query] = { :project_id => @query.project_id, :filters => @query.filters || {} }
    else
      @query = report_query_class.new(:name => '_', :project => @project, :filters => session[:helpdesk_reports_query][:filters] || {})
    end
  end
end
