module Redmine
  module IssueCustomFieldExtensionPatch
    module ListPatch
    	
    	
    	def self.included(receiver)
    	  receiver.extend         ClassMethods
    	  receiver.send :include, InstanceMethods

    	  receiver.class_eval do 
          unloadable
          alias_method_chain :select_edit_tag, :issue_custom_field_extension_patch
    	  end
    	end

    	module ClassMethods
    		
    	end
    	
    	module InstanceMethods
    	  protected
    	    def select_edit_tag_with_issue_custom_field_extension_patch(view, tag_id, tag_name, custom_value, options={})
              #select_edit_tag_without_issue_custom_field_extension_patch(view, tag_id, tag_name, custom_value, options)
              begin
              	if custom_value.customized.new_record? and custom_value.custom_field.type == 'IssueCustomField'
                  custom_field_extension = custom_value.custom_field.issue_custom_field_extension
	                if !custom_field_extension.blank? and custom_field_extension.extends and custom_field_extension.default_value == 'author'
              	    blank_option = ''.html_safe
      			        unless custom_value.custom_field.multiple?
      			          if custom_value.custom_field.is_required?
      			            unless custom_value.custom_field.default_value.present?
      			              blank_option = view.content_tag('option', "--- #{l(:actionview_instancetag_blank_option)} ---", :value => '')
      			            end
      			          else
      			            blank_option = view.content_tag('option', '&nbsp;'.html_safe, :value => '')
      			          end
      			        end
                      
                    if custom_value.value.is_a?(Array)
                      value = (custom_value.value.compact.blank? ? [User.current.id] : custom_value.value)
                    else
                      value = (custom_value.value.nil? ? User.current.id : custom_value.value)
                    end
      			        options_tags = blank_option + view.options_for_select(possible_custom_value_options(custom_value), value)
      			        s = view.select_tag(tag_name, options_tags, options.merge(:id => tag_id, :multiple => custom_value.custom_field.multiple?))
      			        if custom_value.custom_field.multiple?
      			          s << view.hidden_field_tag(tag_name, '')
      			        end
			              return s
              	  end
              	end
              rescue Exception => e
                Rails.logger.error "Error plugin redmine_issue_custom_field_extension File:list_patch.rb str:[] #{e}"
              end
              select_edit_tag_without_issue_custom_field_extension_patch(view, tag_id, tag_name, custom_value, options)
    	    end

    	end
    end
  end
end