class ContextMenuWatchersController < ApplicationController
  unloadable
  include ContextMenuWatchersHelper
  before_filter :permit_params

  before_filter :watchers_find_issues, only: [:new, :autocomplete_for_user]
  before_filter :find_issues, exept: [:new, :autocomplete_for_user]
  before_filter :authorize

  
  before_filter :check_permission_adit_issue
  before_filter :check_permission_delete
  def new
    @projects = @issues.map(&:project).uniq

    @user_watchers = @projects.map do |project|
      project.users.active.sorted.reject{ |user| !user.allowed_to?(:view_issues, project) }
    end.reduce(:&)
    
    @user_watchers = @user_watchers.sort_by(&:name) unless @user_watchers

    respond_to do |format|
      format.js
      format.html{render "new", :locals => {:user_watchers => @user_watchers, :issues => @issues}}#{redirect_to :back}
    end
  end

  def create
    @projects = [@project] if @projects.nil?    
    user_ids = []
    if params[:watcher].is_a?(Hash)
      user_ids << (params[:watcher][:user_ids] || params[:watcher][:user_id])
    else
      user_ids << params[:user_id]
    end
    user_ids = user_ids.flatten.compact.uniq
    begin
      users = User.where(id: user_ids)
    rescue ActiveRecord::RecordNotFound
      render_404
      return
    end
    ActiveRecord::Base.transaction do
      users.each do |user|
        watcher = []        
        @issues.each do |issue|
          project = issue.project
          watcher << {:watchable => issue, :user_id => user.id} if user.allowed_to?(:view_issues, project)
        end
        Watcher.create(watcher) unless watcher.empty?
      end
    end

    @added_users = Watcher.includes(:user).where("watchers.watchable_type = 'Issue' and watchers.watchable_id in (?) and watchers.user_id in (?)", @issues.map(&:id), user_ids).map(&:user).flatten.uniq{|rec| rec.id}
    @added_users = [] if @added_users.nil?
    if params.include?(:from) && params[:from] == "bulk_edit"
      respond_to do |format|
        format.js {render "create_from_bulk_edit", :status => 200}
      end
      return
    else
      respond_to do |format|
        format.js 
      end
      return
    end
  end
  
  def destroy
    @projects = [@project] if @projects.nil?
    
    @user_id = User.find(params[:user_id])
    (render_404; return) if @user_id.nil?
    ActiveRecord::Base.transaction do
      @issues.each do |watched|
        watched.set_watcher(@user_id, false)
      end
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def autocomplete_for_user
    @projects = @issues.map(&:project).uniq

    @user_watchers = @projects.map do |project|
      project.users.active.sorted.limit(20).like(params[:q]).reject{ |user| !user.allowed_to?(:view_issues, project) }
    end.reduce(:&)
    
    @user_watchers = @user_watchers.sort_by(&:name) unless @user_watchers
    
    render :layout => false
  end

  private

    def watchers_find_issues
        @issues = Issue.visible.eager_load(:project).where("issues.id IN (?)", params[:ids])
        raise ActiveRecord::RecordNotFound if @issues.empty?
        raise Unauthorized unless @issues.all?(&:visible?)
        @projects = @issues.collect(&:project).compact.uniq
        #@projects = @issues.collect{|issue| Project.includes(:users).find_by_id(issue.project_id)}.compact.uniq
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
      @allow_delete = @projects.all?{ |project| User.current.allowed_to?(:delete_watchers_in_more_than_one_issue, project)}
    end

    def permit_params
      params.permit(:user_id, :from, :q, :ids, watcher: [:user_ids, :user_id])
    end
end
