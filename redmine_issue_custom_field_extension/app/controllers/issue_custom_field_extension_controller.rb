class IssueCustomFieldExtensionController < ApplicationController
  unloadable
  before_filter :require_admin

  def index
  end

  def create
  	custom_fields = CustomField.where("type='IssueCustomField'").to_a
  	
  	unless params["issue_custom_fields"].nil?
	  params["issue_custom_fields"].each_pair do |key, value|
	  	custom_fields.delete_if{|custom_f| "#{custom_f.id}" == key }
	  	custom_field = IssueCustomFieldExtension.find_or_initialize_by(custom_field_id: key)
      custom_field.extends              = value["extends"].nil? ? false : true 
	    custom_field.notify               = value["notify"].nil? ? false : true 
	    custom_field.add_as_watcher       = value["add_as_watcher"].nil? ? false : true 
      custom_field.default_value        = value["default_value"] || ''  
      custom_field.visible              = value["visible"].nil? ? false : true
	    custom_field.save
	  end
  	end

  	custom_fields.each do |custom_field|
  	  custom_field = IssueCustomFieldExtension.find_or_initialize_by(custom_field_id: custom_field.id)
      custom_field.extends              = false
	    custom_field.notify               = false
	    custom_field.add_as_watcher       = false
      custom_field.default_value        = ''
      custom_field.visible              = false
	    custom_field.save
  	end
  	redirect_to :back, flash: {notice: "Success Updated"}
  end
  
end
