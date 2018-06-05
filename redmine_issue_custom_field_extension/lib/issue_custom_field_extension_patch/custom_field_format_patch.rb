module Redmine
  module IssueCustomFieldExtensionPatch
    module CustomFieldFormatPatch
    	
    	
    	def self.included(receiver)
    	  receiver.extend         ClassMethods
    	  receiver.send :include, InstanceMethods

    	  receiver.class_eval do 
            unloadable

            alias_method_chain :format_as_user, :issue_custom_field_extension
    	  end
    	end

    	module ClassMethods
    	end
    	
    	module InstanceMethods
          def format_as_user_with_issue_custom_field_extension(value)
            begin
              return (value.blank? ? "" : (name.classify.constantize.find_by_id(value.to_i) || Group.find_by_id(value.to_i)).to_s)
            rescue Exception => e
              Rails.logger.error "Plugin redmine_issue_custom_field_extension File:custom_field_format_patch.rb Strings:[] Error: #{e}"
              return format_as_user_without_issue_custom_field_extension(value)
            end
          end
    	end
    end
  end
end