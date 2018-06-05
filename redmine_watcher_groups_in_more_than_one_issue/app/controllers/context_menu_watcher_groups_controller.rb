class ContextMenuWatcherGroupsController < ApplicationController
  unloadable
  before_filter :permit_all
  before_filter :watchers_find_issues, only: [:new, :autocomplete_for_user]
  before_filter :find_issues, exept: [:new, :autocomplete_for_user]
  before_filter :authorize
  before_filter :check_permission_adit_issue
  before_filter :check_permission_delete
  
  def new
    projects = @issues.map(&:project).uniq
    roles = Role.all.to_a.reject{|role| !role.has_permission?(:view_issues)}

    @watcher_groups = projects.map do |project|
      project.memberships.active.includes(:roles).where("users.type='Group'").to_a.reject{ |member| (member.roles & roles).empty? }.map(&:principal)
    end.reduce(:&)

    @watcher_groups = @watcher_groups.sort_by(&:lastname) unless @watcher_groups

    respond_to do |format|
      format.js
      format.html{render "new", :locals => {:issues => @issues, :watcher_groups => @watcher_groups}}#{redirect_to :back}
    end
  end

  def create
    @projects = [@project] if @projects.nil?
    if params[:watcher_group].is_a?(Hash) && request.post?
      group_ids = params[:watcher_group][:group_ids] || [params[:watcher_group][:group_id]]
      @groups = Group.includes(:users).where(id: group_ids).to_a
      @allow_groups = []

      @groups.reject! do |group| 
        !@projects.all?{ |project| group.users.all?{|user| user.allowed_to?(:view_issues, project)} }
      end
      ActiveRecord::Base.transaction do
	      @issues.each do |issue|	        
	        @groups.each do |group|
	          if Watcher.where("watchable_type='#{issue.class}' and watchable_id = #{issue.id} and user_id = '#{group.id}'").limit(1).to_a.blank?
	            # insert directly into table to avoit user type checking
	            Watcher.connection.execute("INSERT INTO `#{Watcher.table_name}` (`user_id`, `watchable_id`, `watchable_type`) VALUES (#{group.id}, #{issue.id}, '#{issue.class.name}')")
	          end
	        end
	      end
	    end
      @watchers = Watcher.includes(:user).where("watchers.watchable_type = 'Issue' and watchers.watchable_id in (?) and watchers.user_id in (?)", @issues.map(&:id), @groups.map(&:id)).pluck(:user_id).uniq
    end
    @added_groups = @watchers.blank? ? [] : Group.where("id IN (?)", @watchers).to_a
    if params.include?(:from) && params[:from] == "bulk_edit"
      respond_to do |format|
        format.html { redirect_to_referer_or {render :text => 'Watcher group added.', :layout => true}}
        format.js{render "create_from_bulk_edit", status: 200}
      end
      return
    else
      respond_to do |format|
        format.html { redirect_to_referer_or {render :text => 'Watcher group added.', :layout => true}}
        format.js 
      end
      return
    end
  end

  def destroy
    @projects = [@project] if @projects.nil?
    
    @group = Group.find_by_id(params[:group_id])
    (render_404; return) if @group.nil?

    ActiveRecord::Base.transaction do
      @issues.each do |issue|
        issue.set_watcher_group(@group, false)
      end
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def autocomplete_for_group
    projects = @issues.map(&:project).uniq

    roles = Role.all.to_a.reject{|role| !role.has_permission?(:view_issues)}

    @groups = projects.map do |project|
      project.memberships.active.includes(:roles).where("users.type='Group' AND users.lastname LIKE ?", "%#{params[:q]}%").to_a.reject{ |member| (member.roles & roles).empty? }.map(&:principal)
    end.reduce(:&)
    #@groups = @members.map(&:principal).flatten

    render :layout => false
  end

private
  def watchers_find_issues
    @issues = Issue.visible.includes(:project).where("issues.id IN (?)", params[:ids]).to_a
    raise ActiveRecord::RecordNotFound if @issues.empty?
    raise Unauthorized unless @issues.all?(&:visible?)
    @projects = @issues.collect(&:project).compact.uniq
    #@projects = @issues.collect{|issue| Project.includes(:principals).find_by_id(issue.project_id)}.compact.uniq    
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
     render_404
  end

  def check_permission_adit_issue
      unless @project.nil?
        unless User.current.allowed_to?(:edit_issues, @project)
          render_403
          return
        else
          return true
        end
      else
        unless @projects.all?{ |project| User.current.allowed_to?(:edit_issues, project)}
          render_403
          return
        else
          return true
        end
      end
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def check_permission_delete
    @allow_delete = @projects.all?{ |project| User.current.allowed_to?(:delete_watcher_groups_in_more_than_one_issue, project)}
  end

  def permit_all
    params.permit!
  end
end
