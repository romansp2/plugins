module Redmine
  module IssueCustomFieldExtensionPatch
  	module RecordListPatch
  		
  		def self.included(receiver)
  		  receiver.extend         ClassMethods
  		  receiver.send :include, InstanceMethods

  		  receiver.class_eval do 
          unloadable
          alias_method_chain :cast_single_value, :issue_custom_field_extension_patch
  		  end
  		end

  		module ClassMethods
  		end
  		
  		module InstanceMethods
  		  def cast_single_value_with_issue_custom_field_extension_patch(custom_field, value, customized=nil)
  		  	begin
  		  	  if custom_field.type == 'IssueCustomField'
              custom_field_extension = custom_field.issue_custom_field_extension
              if !custom_field_extension.blank? and custom_field_extension.extends
                return ((target_class.find_by_id(value.to_i) || Group.find_by_id(value.to_i)) if value.present?)
              end
  		  	  end
  		  	rescue Exception => e
            Rails.logger.error "Error plugin redmine_issue_custom_field_extension File:record_list_patch.rb str:[19-26] #{e}"
  		  	end
          return cast_single_value_without_issue_custom_field_extension_patch(custom_field, value, customized)  
  		  end
  		end
  	end

  end

end