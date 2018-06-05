class UsersFieldFromTo < ActiveRecord::Base
  unloadable
  
  serialize :fields_from_to, JSON

  belongs_to :hot_button

  def hash_custom_fields
  	#{set_field_id: set_field_from_obj}
  	fields_ = {}
  	fields_from_to.each do |key, value|
  	  if value != "assigned" and value != "author"
  	  	fields_[key] = CustomField.find_by_id(value)
  	  else
  	  	custom_field = CustomField.new
        if value == "assigned"
  	  	  custom_field.name = l(:field_assigned_to)
        end
        if value == "author"
          custom_field.name = l(:author_of_issue , scope: [:hot_buttons])
        end
  	  	fields_[key] = custom_field
  	  end
  	end
    fields_
  end

  def set_issue_fields_from_to(issue_old, issue_updated)
  	issue_updated.category = hot_button.category
  	unless hot_button.priority.blank?
  	  issue_updated.priority = hot_button.priority
    end
    @issue_obj         = issue_old
    #@issue_cfs         = issue.custom_values.uniq{|cf_v| cf_v.custom_field_id}.map(&:custom_field)
    @issue_cf_v        = issue_old.custom_values#.dup
    @issue_assigned_to = issue_old.assigned_to#.dup
    @available_custom_fields = issue_updated.available_custom_fields

    set_issue = {}
    fields_from_to.each do |set_field, set_field_from|#|field_from, field_to|
    	set_field_obj        = CustomField.find_by_id(set_field)      if set_field != "assigned"
    	set_field_from_obj   = CustomField.find_by_id(set_field_from) if set_field_from != "assigned"
    	permission = true 
    	permission = false if set_field      != "assigned" and set_field_obj.nil?
      permission = false if set_field_from != "assigned" and set_field_from_obj.nil?
        #permission = false if permission and (set_field == "assigned" or set_field_obj.multiple == false) and (set_field_from != "assigned" and (!set_field_from_obj.nil? and set_field_from_obj.multiple))
    #permission = false if permission and set_field == "assigned"  and !set_field_from_obj.nil?        and set_field_from_obj.multiple
    #permission = false if permission and !set_field_obj.nil?      and set_field_obj.multiple == false and !set_field_from_obj.nil? and set_field_from_obj.multiple
      permission = false if permission and !set_field_from_obj.nil? and @available_custom_fields.find{|cf| "#{cf.id}" == set_field_from}.nil?
      permission = false if permission and !set_field_obj.nil?      and @available_custom_fields.find{|cf| "#{cf.id}" == set_field}.nil?
      permission = false if permission and !set_field_from_obj.nil? and (set_field_from_obj.type != 'IssueCustomField' or set_field_from_obj.field_format != 'user')
      permission = false if permission and !set_field_obj.nil?      and (set_field_obj.type != 'IssueCustomField'      or set_field_obj.field_format != 'user')


      if permission == false and set_field_from == "author"
        if set_field == "assigned"
          issue_updated.assigned_to_id = @issue_obj.author_id
        else
          set_issue["#{set_field_obj.id}"] = ["#{@issue_obj.author_id}"]
        end
      end
    	if permission and set_field != set_field_from
	      if set_field == "assigned"
          custom_field_value = @issue_cf_v.find{|cf_v| cf_v.custom_field_id == set_field_from_obj.id}
          unless custom_field_value.nil?
            user_from_cf = @issue_obj.assignable_users.find{|user| "#{user.id}" == custom_field_value.value}
            issue_updated.assigned_to = user_from_cf unless user_from_cf.nil?
          end 
	      else
	        if set_field_from == "assigned"
            unless @issue_obj.assigned_to.nil?
              set_issue[set_field] = "#{@issue_obj.assigned_to.id}" 
            end
          else
            set_issue["#{set_field_obj.id}"] = @issue_cf_v.map do |cf_v|
                                                 cf_v.value if cf_v.custom_field_id == set_field_from_obj.id
                                               end.compact

            if set_field_obj.multiple == false and set_field_from_obj.multiple == true
              set_issue["#{set_field_obj.id}"] = set_issue["#{set_field_obj.id}"].first 
            end

	        end
	      end
	    end
    		
    end#fields_from_to.each
  	set_issue  
  end

  def hash_from_to
    @hash_from_to = {}
  end

  def field_assigned_to
  	assigned_to = fields_from_to["assigned"]
  end
  
end
