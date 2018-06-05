module Redmine
  module ChangeDefaultBehaviorForParentIssue
    module IssuePatch
    	def self.included(receiver)
    		receiver.extend         ClassMethods
    		receiver.send :include, InstanceMethods
            
            receiver.class_eval do
		  	  unloadable # Send unloadable so it will not be unloaded in development
		      alias_method_chain :recalculate_attributes_for, :change_default_behavior_for_parent_issue
		      #alias_method_chain :safe_attributes=, :change_default_behavior_for_parent_issue
		      alias_method_chain :total_spent_hours, :change_default_behavior_for_parent_issue
			end
    		
    	end

    	module ClassMethods
    		
    	end
    	
    	module InstanceMethods
    	  private
    	    def recalculate_attributes_for_with_change_default_behavior_for_parent_issue(issue_id)
              #recalculate_attributes_for_without_redmine_change_default_behavior_for_parent_issue(issue_id)
    	    end

    	    def safe_attributes_with_change_default_behavior_for_parent_issue=(attrs, user=User.current)
    	      #copy = attrs.select {|key, value| %w(priority_id done_ratio start_date due_date estimated_hours).include?(key)}
              #safe_attributes_without_redmine_change_default_behavior_for_parent_issue(attrs, user)
              return unless attrs.is_a?(Hash)

			  attrs = attrs.deep_dup

			  # Project and Tracker must be set before since new_statuses_allowed_to depends on it.
			  if (p = attrs.delete('project_id')) && safe_attribute?('project_id')
			    if allowed_target_projects(user).collect(&:id).include?(p.to_i)
			      self.project_id = p
			    end
			  end

			  if (t = attrs.delete('tracker_id')) && safe_attribute?('tracker_id')
			    self.tracker_id = t
			  end

			  #if (s = attrs.delete('status_id')) && safe_attribute?('status_id')
			  #  if new_statuses_allowed_to(user).collect(&:id).include?(s.to_i)
			  #    self.status_id = s
			  #  end
			  #end
			  statuses_allowed = new_statuses_allowed_to(user)
			  if (s = attrs.delete('status_id')) && safe_attribute?('status_id')
			    if statuses_allowed.collect(&:id).include?(s.to_i)
			      self.status_id = s
			    end
			  end
			  if new_record? && !statuses_allowed.include?(status)
			    self.status = statuses_allowed.first || default_status
			  end

			  attrs = delete_unsafe_attributes(attrs, user)
			  return if attrs.empty?

     		  #unless leaf?
		        #attrs.reject! {|k,v| %w(priority_id done_ratio start_date due_date estimated_hours).include?(k)}
			  #end

			  if attrs['parent_issue_id'].present?
			    s = attrs['parent_issue_id'].to_s
			    unless (m = s.match(%r{\A#?(\d+)\z})) && (m[1] == parent_id.to_s || Issue.visible(user).exists?(m[1]))
			      @invalid_parent_issue_id = attrs.delete('parent_issue_id')
			    end
			  end

			  #if attrs['custom_field_values'].present?
			  #  attrs['custom_field_values'] = attrs['custom_field_values'].reject {|k, v| read_only_attribute_names(user).include? k.to_s}
			  #end
			  if attrs['custom_field_values'].present?
			    editable_custom_field_ids = editable_custom_field_values(user).map {|v| v.custom_field_id.to_s}
			    attrs['custom_field_values'].select! {|k, v| editable_custom_field_ids.include?(k.to_s)}
			  end

			  #if attrs['custom_fields'].present?
			  #  attrs['custom_fields'] = attrs['custom_fields'].reject {|c| read_only_attribute_names(user).include? c['id'].to_s}
			  #end
			  if attrs['custom_fields'].present?
			    editable_custom_field_ids = editable_custom_field_values(user).map {|v| v.custom_field_id.to_s}
			    attrs['custom_fields'].select! {|c| editable_custom_field_ids.include?(c['id'].to_s)}
			  end

			  # mass-assignment security bypass
			  assign_attributes attrs, :without_protection => true
    	    end

    	    def total_spent_hours_with_change_default_behavior_for_parent_issue
			  #@total_spent_hours ||= self.time_entries.sum(&:hours).to_f || 0.0
			  spent_hours
			end

    		
    	end
    end
  end
end