class GroupIssueController < ApplicationController
  unloadable
  before_filter :require_login
  before_filter :permit_params

  before_filter :find_project, :allowed_add_groups

  def new
  	group_ids = []
    if params[:groups_issue].is_a?(Hash)
      group_ids << (params[:groups_issue][:group_ids] || params[:groups_issue][:group_id])
    else
      group_ids << params[:group_id]
    end
  	@group_ids = group_ids.flatten.compact.uniq
  	@groups = []
  	unless @group_ids.empty?
      request = "#{Principal.table_name}.type='Group' AND #{Principal.table_name}.status=#{Principal::STATUS_ACTIVE}"
      request += " AND #{Principal.table_name}.id IN (?)" 
      @groups = @project.principals.where(request, @group_ids).sorted
    end
  end

  def destroy
    group_ids = []
    if params[:groups_issue].is_a?(Hash)
      group_ids << (params[:groups_issue][:group_ids] || params[:groups_issue][:group_id])
    else
      group_ids << params[:group_id]
    end
    @group_id = params[:id]
    @group_ids = group_ids.flatten.compact.uniq.delete_if{|id| id == "#{@group_id}"}

    @groups = []
    unless @group_ids.empty?
      request = "#{Principal.table_name}.type='Group' AND #{Principal.table_name}.status=#{Principal::STATUS_ACTIVE}"
      request += " AND #{Principal.table_name}.id IN (?)" 
      @groups = @project.principals.where(request, @group_ids).sorted
    end
  end

  def autocomplete_for_group
  	group_ids = []
    if params[:groups_issue].is_a?(Hash)
      group_ids << (params[:groups_issue][:group_ids] || params[:groups_issue][:group_id])
    else
      group_ids << params[:group_id]
    end
    @group_ids = group_ids.flatten.compact.uniq
  	q = params[:q].to_s
    request = "#{Principal.table_name}.type='Group' AND #{Principal.table_name}.status=#{Principal::STATUS_ACTIVE}"
    unless @group_ids.empty?
      request += " AND #{Principal.table_name}.id NOT IN (?)" 
      @groups = @project.principals.where(request, @group_ids).like(q).limit(100).sorted
    else
      @groups = @project.principals.where(request).like(q).limit(100).sorted
    end

    render :layout => false
  end

  def add_groups
  	group_ids = []
    if params[:groups_issue].is_a?(Hash)
      group_ids << (params[:groups_issue][:group_ids] || params[:groups_issue][:group_id])
    else
      group_ids << params[:group_id]
    end
    @group_ids = group_ids.flatten.compact.uniq
    @groups = []
    request = "#{Principal.table_name}.type='Group' AND #{Principal.table_name}.status=#{Principal::STATUS_ACTIVE}"

    unless @group_ids.empty?
      request += " AND #{Principal.table_name}.id IN (?)"
      @groups = @project.principals.where(request, @group_ids).sorted
    else
      @groups = @project.principals.where(request).sorted
    end
  end

  
  private

    def find_project
      begin
        project_id = params[:project_id]
        @project = Project.find(project_id)
      rescue ActiveRecord::RecordNotFound
        render_404
      end
    end

    def allowed_add_groups
      unless User.current.allowed_to?(:add_issue_watchers, @project)
        render_403
      end
    end

    def permit_params
      params.permit!
    end

end
