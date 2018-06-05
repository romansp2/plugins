module HotButtonsPatch
	module IssuesControllerPatch
	  def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods

		receiver.class_eval do 
		  skip_before_filter :authorize,  :only => [:hot_button_update_form]
		  before_filter :hot_button_find_issue, :only => [:hot_button_update_form]
		  before_filter :hot_button_authorize, only: [:hot_button_update_form]

	      before_filter :hot_button, only: [:hot_button_update_form]
		end
	  end

	  module ClassMethods
	  end

	  module InstanceMethods


	  	def hot_button_update_form
          return unless update_issue_from_params
          render :action => 'hot_button_update_form.js.erb'
	      #respond_to do |format|
	      #  format.html { }
	      #  format.js
	      #end
	  	end

	  	private
	  	  def hot_button_find_issue
            find_issue
	  	  end
	  	  def hot_button_authorize
            authorize
	  	  end
	  	  def hot_button
	  	  	#begin
	  	      if request.xhr? && params.include?("hot_button_id") && !@issue.new_record?
		  	    hot_button = HotButton.eager_load(:tracker, :status, :role).find_by_id(params["hot_button_id"])
		  	    user_roles = User.current.roles_for_project(@issue.project)
                allowed_statuses = @issue.new_statuses_allowed_to(User.current)

		  	    if !hot_button.blank? && @issue.tracker.id == hot_button.for_tracker_id && allowed_statuses.include?(hot_button.status)
		  	      issue_old = Issue.eager_load(:tracker, :status, :priority).find_by_id @issue.id
			  	  @issue.tracker = hot_button.tracker
			  	  @issue.status  = hot_button.status
			  	  users_field_from_to = hot_button.users_field_from_to

			  	  custom_field_new_values = users_field_from_to.set_issue_fields_from_to(issue_old, @issue)
             
                  params["issue"]["assigned_to_id"] = @issue.assigned_to_id#users_field_from_to.fields_from_to["assigned"] || params["issue"]["assigned_to_id"]
                  params["issue"]["tracker_id"]   = @issue.tracker_id
                  params["issue"]["status_id"]    = @issue.status_id
                  params["issue"]["priority_id"]  = @issue.priority_id
                  params["issue"]["category_id"]  = @issue.category_id

                  params_custom_field_values = params["issue"]["custom_field_values"]
			  	  @issue.custom_field_values = custom_field_new_values
                  
     
			  	  custom_field_new_values.each_pair do |key, value|
			  	  	if params_custom_field_values[key].instance_of?(Array) and value.instance_of?(Array)
                      params_custom_field_values[key] = value.map(&:to_s)
			  	    elsif params_custom_field_values[key].instance_of?(Array) and !value.instance_of?(Array)
                      params_custom_field_values[key] = ["#{value}"]
                    elsif !params_custom_field_values[key].instance_of?(Array) and value.instance_of?(Array)
                      params_custom_field_values[key] = "#{value.first}"
                    elsif !params_custom_field_values[key].instance_of?(Array) and !value.instance_of?(Array)
                      params_custom_field_values[key] = "#{value}"
			  	    end
			  	  end
			  	else
			  	  respond_to do |format|
                    format.js{render js: ("$('form#issue-form input[name=hot_button_id]').remove(); alert('"+l(:error_you_can_not_update_form_check_settings_for_status, project_user_roles: user_roles.map(&:name).join(', '), tracker: @issue.tracker.name, status: @issue.status.name, hot_button: hot_button.name, hot_button_role: hot_button.role, hot_button_tracker: hot_button.tracker.name, hot_button_status: hot_button.status.name, scope: [:hot_buttons])+"')")}
			  	  end
			  	  return false
			  	end
	          end
	          #if params.include?("hot_button_id") && @issue.new_record?
	          #end
	  	  	#rescue Exception => e
	  	  	    #flash[:error] = 
		  	    #render_error l(:error_no_tracker_in_project)
                #return false
	  	  	#end
	  	  	
	  	  end
	  end
	end
end