class HotButtonsController < ApplicationController
  unloadable

  before_filter :require_login 
  before_filter :permit_params
  before_filter :find_project_by_project_id, :authorize
  #before_filter :check_for_default_issue_status, :only => [:new, :create, :update_form]
  before_filter :find_hot_button,                :only => [:edit, :update]
  before_filter :build_new_issue_from_params,    :only => [:new, :create, :update, :update_form]
  before_filter :build_issue_from_hot_buttons,   :only => [:edit]

  helper :custom_fields
  include CustomFieldsHelper

  def index
  end


  def new

  end

  def show
  end

  def edit

  end

  def update
    if !@error_messages.empty? and !request.xhr?
      respond_to do |format|
        flash[:error] = @error_messages.join('<br>')
        format.html{render 'new'}        
      end
      return 
    end
    #
    @hot_button.name     =  @issue.subject
    @hot_button.role     =  @role
    @hot_button.tracker  =  @issue.tracker
    @hot_button.for_tracker_id  =  @for_tracker_id
    @hot_button.status   =  @issue.status 
    @hot_button.priority =  @issue.priority
    @hot_button.category =  @issue.category
    

    users_field_from_to = ( !params["issue"].nil? and !params["issue"]["cf"].nil? ? params["issue"]["cf"] : {})
    @hot_button.build_users_field_from_to.fields_from_to = users_field_from_to
    
    if @hot_button.save
      respond_to do |format|
        flash[:notice] = l(:success_update_hot_button, :name     => @hot_button.name, 
                                                       :project  => @issue.project.name, 
                                                       :tracker  => @hot_button.tracker.name, 
                                                       :status   => @hot_button.status.name,
                                                       :priority => (@hot_button.priority.nil? ? "" : @hot_button.priority.name), 
                                                       :role     => @hot_button.role.name, 
                                                       :scope    => [:hot_buttons]) 
        format.html{redirect_to hot_buttons_path(project_id: @project.identifier)}
      end
      return 
    else
      respond_to do |format|
        flash[:error] = @hot_button.errors.full_messages.join("<br>").html_safe
        format.html{render 'new'}
      end
      return
    end
  end

  def update_form
  end 

  def create
    if !@error_messages.empty? and !request.xhr?
      respond_to do |format|
        flash[:error] = @error_messages.join('<br>')
        format.html{render 'new'}        
      end
      return 
    end
    #
    @hot_button = HotButton.new
    @hot_button.role     =  @role
    @hot_button.name     =  @issue.subject
    @hot_button.projects << @issue.project
    @hot_button.tracker  =  @issue.tracker
    @hot_button.for_tracker_id  =  @for_tracker_id
    @hot_button.status   =  @issue.status 
    @hot_button.priority =  @issue.priority
    @hot_button.category =  @issue.category
    
    #users_field_from_to
    users_field_from_to = ( !params["issue"].nil? and !params["issue"]["cf"].nil? ? params["issue"]["cf"] : {})
    @hot_button.build_users_field_from_to.fields_from_to = users_field_from_to

    if @hot_button.save
      respond_to do |format|
        flash[:notice] = l(:success_create_hot_button, :name     => @hot_button.name, 
                                                       :project  => @issue.project.name, 
                                                       :tracker  => @hot_button.tracker.name, 
                                                       :status   => @hot_button.status.name,
                                                       :priority => (@hot_button.priority.nil? ? "" : @hot_button.priority.name), 
                                                       :role     => @hot_button.role.name, 
                                                       :scope    => [:hot_buttons]) 
        format.html{redirect_to hot_buttons_path(project_id: @project.identifier)}
      end
      return 
    else
      respond_to do |format|
        flash[:error] = @hot_button.errors.full_messages.join("<br>").html_safe
        format.html{render 'new'}
      end
      return
    end
  end

  def destroy
    @hot_button = HotButton.find_by_id(params[:id])
    @hot_button.destroy
  end
  
  private

    #def check_for_default_issue_status
    #  if IssueStatus.default.nil?
    #    render_error l(:error_no_default_issue_status)
    #    return false
    #  end
    #end

    def build_new_issue_from_params
      #Very importante when relation with project check if exist role tracker custom fields
      #flash[:error] = issue.errors.full_messages.join("<br>").html_safe
      @hot_button = HotButton.includes(:users_field_from_to).find_by_id(params["id"]) if params.include?("id")
      
      @error_messages = []
      @issue = Issue.new

      @issue.project = @project
      @issue_project = Project.visible.find_by_id(params[:issue][:project_id]) unless params[:issue].nil?
      @issue.project = (@issue_project.nil? ? @project : @issue_project) 
      
      @issue.subject = (params[:issue][:subject] unless params[:issue].nil?) || ""
      #role
      @roles = Role.joins(:members).where("members.project_id = ?", @issue.project.id).select("DISTINCT roles.id, roles.name, roles.builtin")
      @role  = Role.find(params[:issue][:role_id]) if (!params[:issue].nil? and !params[:issue][:role_id].blank?)
      @role = @roles.first if @role.nil?
      if @roles.blank?
        @error_messages << l(:error_can_not_find_roles_in_project, project: @issue.project.name, scope: [:hot_buttons])
      end
      # Tracker
      # Tracker must be set before custom field values
      @trackers = @issue.project.trackers
      @tracker  = @trackers.find{|tracker| "#{tracker.id}" == params[:issue].try(:[], :tracker_id)} || @trackers.first
      @for_tracker_id = @trackers.find{|tracker| "#{tracker.id}" == params[:issue].try(:[], :for_tracker_id)}.try(:id) || @hot_button.try(:for_tracker_id)

      #unless @project.nil?
      #  @tracker ||= @project.trackers.find((params[:issue][:tracker_id] unless params[:issue].nil?) || :first)
      #else 
      #  @tracker ||= Tracker.find((params[:issue][:tracker_id] unless params[:issue].nil?) || :first)
      #end
      
      @disabled_core_fields = Tracker.disabled_core_fields [@tracker]

      @issue.tracker = @tracker
      if @issue.tracker.blank?
        @error_messages << l(:error_can_not_find_tracker_in_project, project: @issue.project.name, scope: [:hot_buttons])
      end
      #priority
      @priorities     = IssuePriority.active
      @issue.priority = IssuePriority.active.find_by_id(params[:issue][:priority_id]) unless params[:issue].nil?
      #status
      status         = IssueStatus.find_by_id(params[:issue][:status_id]) if (!params[:issue].nil? and !params[:issue][:status_id].blank?)
      initial_status = @issue.tracker.default_status

      if @role.nil?
        @allowed_statuses = initial_status.find_new_statuses_allowed_to(@roles, @tracker).uniq.sort
      else
        @allowed_statuses = initial_status.find_new_statuses_allowed_to([@role], @tracker).sort
      end
      @issue.status = (@allowed_statuses.include?(status) ? status : @allowed_statuses.first)
      #category
      if !params[:issue].nil? and !params[:issue][:category_id].blank?
        @issue.category = @issue.project.issue_categories.where("issue_categories.id = ?", params[:issue][:category_id]).first
      end
      #custom fields
      custom_fields
    end

    def custom_fields
      custom_fields = @issue.editable_custom_field_values.delete_if{|cf| cf.custom_field.field_format != "user"}
      cf_multiple_single = {multiple: [], single: []}
      
      custom_fields.each{|cf| ( cf.custom_field.multiple ? (cf_multiple_single[:multiple] << cf.custom_field) : (cf_multiple_single[:single] << cf.custom_field) ) }

      
      @custom_fields_split_selected = ( ( !params["issue"].nil? and !params["issue"]["cf"].nil?) ? params["issue"]["cf"] : {})
      if @custom_fields_split_selected.empty? and !@hot_button.nil?
        @custom_fields_split_selected = ( @hot_button.users_field_from_to.nil? ? {} : @hot_button.users_field_from_to.fields_from_to )
      end

      @custom_fields_split   = {} #{cf_object => [[cf.id, cf.name],..., ["assigned_to", "Assigned"] ]} for select tag
      custom_fields_multiple = {}
      custom_fields_single   = {}
      authot_of_issue        = [l(:author_of_issue , scope: [:hot_buttons]), "author"]

      cf_multiple_single[:multiple].each_with_index do |cf, index|
        custom_fields_split = cf_multiple_single[:multiple].dup
        #custom_fields_split.delete_at(index) #delete self from select
        custom_fields_split = custom_fields_split.map{|cf_| [cf_.name, "#{cf_.id}"]}
        if @issue.safe_attribute? 'assigned_to_id'
          custom_fields_split << ["#{l(:field_assigned_to)}", "assigned"]
        end
        unless cf_multiple_single[:single].empty?
           custom_fields_split += cf_multiple_single[:single].map{|cf_| [cf_.name, "#{cf_.id}"]}
        end
        #@custom_fields_split[cf] = custom_fields_split unless custom_fields_split.empty?
        #Add author of issue in list
        custom_fields_split << authot_of_issue
        custom_fields_multiple[cf] = custom_fields_split unless custom_fields_split.empty?
      end
      cf_multiple_single[:single].each_with_index do |cf, index|
        custom_fields_split = cf_multiple_single[:single].dup
        #custom_fields_split.delete_at(index) #delete self from select
        custom_fields_split = custom_fields_split.map{|cf_| [cf_.name, "#{cf_.id}"]}

        
        if @issue.safe_attribute? 'assigned_to_id'
          custom_fields_split << ["#{l(:field_assigned_to)}", "assigned"]
        end
        #@custom_fields_split[cf] = custom_fields_split unless custom_fields_split.empty?

        #add multiple fields
        custom_fields_split += cf_multiple_single[:multiple].map{|cf_| [cf_.name, "#{cf_.id}"]}
        #Add author of issue in list
        custom_fields_split << authot_of_issue
        custom_fields_single[cf] = custom_fields_split unless custom_fields_split.empty?
      end
      #@custom_fields_split["assigned_to"] = []
      #@custom_fields_split["assigned_to"] << ["#{l(:field_assigned_to)}", "assigned"] if @issue.safe_attribute? 'assigned_to_id'
      #@custom_fields_split["assigned_to"] += cf_multiple_single[:single].map{|cf_| [cf_.name, "#{cf_.id}"]}
      
      custom_fields_single["assigned_to"] = []
      custom_fields_single["assigned_to"] << ["#{l(:field_assigned_to)}", "assigned"] if @issue.safe_attribute? 'assigned_to_id'
      custom_fields_single["assigned_to"] += cf_multiple_single[:single].map{|cf_| [cf_.name, "#{cf_.id}"]}
      custom_fields_single["assigned_to"] += cf_multiple_single[:multiple].map{|cf_| [cf_.name, "#{cf_.id}"]}
      
      #Add author of issue in list
      custom_fields_single["assigned_to"] << authot_of_issue
      
          
      #custom_fields_single.each do |single_field_name, value_from_single_field|
      #  multiple_fields_name = custom_fields_multiple.keys
      #  multiple_fields_name.each do |field_name| 
      #    custom_fields_multiple[field_name] += value_from_single_field
      #  end
      #end
      @custom_fields_split.merge!(custom_fields_single)
      @custom_fields_split.merge!(custom_fields_multiple)
    end

    def find_hot_button
      @hot_button = HotButton.includes(:users_field_from_to).find_by_id params[:id]
      if @hot_button.nil?
        render_403
        return false
      end  
    end

    def build_issue_from_hot_buttons
      @error_messages = []
      @issue = Issue.new

      @issue.project = @project
      @issue.subject = @hot_button.name
      #role
      @roles = Role.joins(:members).where("members.project_id = ?", @issue.project.id).select("DISTINCT roles.id, roles.name, roles.builtin")
      @role  = @hot_button.role
      if @roles.blank?
        @error_messages << l(:error_can_not_find_roles_in_project, project: @issue.project.name, scope: [:hot_buttons])
      end
      unless @roles.include?(@role)
        @error_messages << l(:error_can_not_find_role_in_project, role: @role, project: @issue.project.name, scope: [:hot_buttons])
      end
      # Tracker
      # Tracker must be set before custom field values
      @issue.tracker = @hot_button.tracker
      @trackers      = @issue.project.trackers
      unless @trackers.include?(@issue.tracker)
        @error_messages << l(:error_can_not_find_tracker_in_project, tracker: @issue.tracker, project: @issue.project.name, scope: [:hot_buttons])
      end
      @for_tracker_id = @hot_button.for_tracker_id

      @disabled_core_fields = Tracker.disabled_core_fields [@issue.tracker]
      #priority
      @priorities     = IssuePriority.active
      @issue.priority = @hot_button.priority
      #status
      status         = @hot_button.status
      initial_status = @issue.tracker.default_status
      @allowed_statuses = initial_status.find_new_statuses_allowed_to([@role], @issue.tracker).sort

      @issue.status = (@allowed_statuses.include?(status) ? status : @allowed_statuses.first)
      #category
      @issue.category = @hot_button.category
       
      #custom fields
      custom_fields
    end

    def permit_params
      params.permit(:id, issue: [ :cf, :project_id, :subject, :role_id, :tracker_id, :for_tracker_id, :priority_id, :status_id, :category_id ])
    end
    
end
