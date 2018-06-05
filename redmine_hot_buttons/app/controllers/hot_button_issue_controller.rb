class HotButtonIssueController < ApplicationController
  unloadable
  before_filter :require_login 
  before_filter :find_issue
  before_filter :permit_params
  before_filter :check_edit_issue_permission
  before_filter :check_hot_button_can_be_set, only: [:set_issue_to]

  helper :custom_fields
  include CustomFieldsHelper

  def index
    role_ids = User.current.roles_for_project(@project).pluck(:id)
    #tracker = @issue.tracker
    #allowed_statuses = issue.status.find_new_statuses_allowed_to(roles, tracker).uniq.sort
    unless role_ids.nil?
      tracker_ids  = @project.trackers.pluck(:id)
      
      @hot_buttons = @project.hot_buttons.eager_load(:role, :tracker, :status).where("hot_buttons.role_id IN (?) AND hot_buttons.tracker_id IN (?)", role_ids, tracker_ids).to_a
      unless @hot_buttons.empty?
        #@hot_buttons.delete_if do |hot_button| 
        #  (hot_button.status_id == @issue.status.id) and (hot_button.tracker_id == @issue.tracker.id)
        #end
        @hot_buttons.delete_if do |hot_button| 
          if hot_button.for_tracker_id.nil?
            false
          elsif hot_button.for_tracker_id != @issue.tracker.id
            true
          end
        end

        @hot_buttons.delete_if{|hot_button_| !tracker_ids.include?(hot_button_.tracker_id) }

        @hot_buttons.delete_if do |hot_button|
          @issue.tracker      = hot_button.tracker
          allowed_statuses    = @issue.new_statuses_allowed_to(User.current, true)
          #allowed_statuse_ids = allowed_statuses.map(&:id)

          #allowed_statuse_ids.include?(hot_button.status_id)
          !allowed_statuses.include?(hot_button.status)
        end
        
        #trackers.each do |tracker|
        #  #hot_button_alloweds = @hot_buttons.map{|hot_button_| (hot_button_ if hot_button_.tracker_id == tracker.id)}.compact
        #  hot_button_alloweds = @hot_buttons.find_all{|hot_button_| hot_button_.tracker_id == tracker.id }
        #  unless hot_button_alloweds.empty?
        #    @issue.tracker   = tracker
        #    allowed_statuses = @issue.new_statuses_allowed_to(User.current, true)#@issue.status.find_new_statuses_allowed_to(roles, tracker).uniq.sort 
        #    hot_button_alloweds.each do |hot_button_allowed|
        #      unless allowed_statuses.include?(hot_button_allowed.status)
        #        byebug
        #        @hot_buttons.delete_if{|hot_button| hot_button.id == hot_button_allowed.id}
        #      end
        #    end
        #  end
        #end
      end#unless hot_buttons.empty?
    end
  end

  def set_issue_to
  end

  private
    def check_edit_issue_permission
      if User.current.allowed_to?(:edit_issues, @project)
        return true
      else
        render_403
        return false
      end
    end

    def check_hot_button_can_be_set
      @error_messages = []
      
      @roles    = User.current.roles_for_project(@project)
      trackers  = @project.trackers

      @hot_button = @project.hot_buttons.eager_load(:role, :tracker, :status).where("hot_buttons.id = ?", params["hot_button_id"]).first
      #@hot_button = @project.hot_buttons.includes(:role, :tracker, :status).where("hot_buttons.id = ?          AND 
      #	                                                                           hot_buttons.tracker_id <> ? AND
      #	                                                                           hot_buttons.status_id  <> ?", 
      #	                                                                           params["hot_button_id"],
      #	                                                                           @issue.tracker.id,
      #	                                                                           @issue.status.id
      #	                                                                           ).first
      
      #@hot_button = @hot_button.delete_if{|hot_button| (hot_button.status_id == @issue.status.id && hot_button.tracker_id == @issue.tracker.id)}.first
      
      #@tracker  = @hot_button.tracker
      #hot_button_issue = Issue.new
      #hot_button_issue.author  = User.current
      #hot_button_issue.tracker = @hot_button.tracker 
      #hot_button_issue.status  = @hot_button.status 
      #@trackers = @project.trackers
      #@allowed_statuses = hot_button_issue.status.find_new_statuses_allowed_to(@roles, hot_button_issue.tracker)
      
      #@allowed_statuses = hot_button_issue.new_statuses_allowed_to(User.current, true)
      @issue.tracker    = @hot_button.tracker
      @allowed_statuses = @issue.new_statuses_allowed_to(User.current, true)
      if @hot_button.blank?
        @error_messages << l(:error_can_not_find_hot_button_for_project, project: @project.name, scope: [:hot_buttons])
        respond_to do |format|
          format.js{render 'error_messages'}
        end
        return false
      end
      if @allowed_statuses.include?(@hot_button.status) == false or trackers.include?(@hot_button.tracker) == false
        @error_messages << l(:error_check_settings_in_hot_buttons_role_tracker_status, scope: [:hot_buttons])
        respond_to do |format|
          format.js{render 'error_messages'}
        end
        return false
      end
      unless @roles.include?(@hot_button.role)
        @error_messages << l(:error_you_have_not_role_that_in_hot_button, scope: [:hot_buttons])
        respond_to do |format|
          format.js{render 'error_messages'}
        end
        return false
      end
    end

    def permit_params
      params.permit(:hot_button_id)
    end
end
