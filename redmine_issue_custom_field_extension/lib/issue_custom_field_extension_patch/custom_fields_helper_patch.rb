module Redmine
  module IssueCustomFieldExtensionPatch
    module CustomFieldsHelperPatch
    	
    	def self.included(receiver)
    		receiver.extend         ClassMethods
    		receiver.send :include, InstanceMethods

            
    		receiver.class_eval do 
    		  unloadable # Send unloadable so it will not be unloaded in development
              alias_method_chain :custom_field_tag, :issue_custom_field_extension
    		end
    	end

    	module ClassMethods
    	end
    	
    	module InstanceMethods
    	  # Return custom field html tag corresponding to its format
    	  def custom_field_tag_with_issue_custom_field_extension(name, custom_value)
    	  	begin
	          custom_field = custom_value.custom_field

			  field_format = Redmine::CustomFieldFormat.find_by_name(custom_field.field_format)
			  if !@issue.nil? and @issue.new_record? and custom_field.field_format == 'user' and field_format.try(:edit_as) == "list"
	            custom_field_extension = custom_field.issue_custom_field_extension
  
                if !custom_field_extension.blank? and custom_field_extension.extends and custom_field_extension.default_value == 'author'
                  field_name = "#{name}[custom_field_values][#{custom_field.id}]"
				  field_name << "[]" if custom_field.multiple?
				  field_id = "#{name}_custom_field_values_#{custom_field.id}"

				  tag_options = {:id => field_id, :class => "#{custom_field.field_format}_cf"}

			      blank_option = ''.html_safe
			      unless custom_field.multiple?
			        if custom_field.is_required?
			          unless custom_field.default_value.present?
			            blank_option = content_tag('option', "--- #{l(:actionview_instancetag_blank_option)} ---", :value => '')
			          end
			        else
			          blank_option = content_tag('option')
			        end
			      end
			      s = select_tag(field_name, blank_option + options_for_select(custom_field.possible_values_options(custom_value.customized), User.current.id ),
			        tag_options.merge(:multiple => custom_field.multiple?))
			      if custom_field.multiple?
			        s << hidden_field_tag(field_name, '')
			      end
   			        s
			    else 
				  custom_field_tag_without_issue_custom_field_extension(name, custom_value)
				end
			  else 
	            custom_field_tag_without_issue_custom_field_extension(name, custom_value)
			  end#if !@issue.nil? and @issue.new_record? and custom_field.field_format == 'user' and field_format.try(:edit_as) == "list"
		    rescue Exception => e
		      Rails.logger.error "Plugin redmine_issue_custom_field_extension File:custom_fields_helper_patch.rb Strings:[] Error: #{e}"
    	  	  custom_field_tag_without_issue_custom_field_extension(name, custom_value)
    	  	end
    	  end#def custom_field_tag_with_issue_custom_field_extension(name, custom_value)
    	end#module InstanceMethods

    end

  end
end