module Redmine
  module IssueCustomFieldExtensionPatch
    module CustomFieldPatch
    	def self.included(receiver)
    		receiver.extend         ClassMethods
    		receiver.send :include, InstanceMethods

    		receiver.class_eval do 
    	    unloadable # Send unloadable so it will not be unloaded in development
          has_one :issue_custom_field_extension, dependent: :destroy

    		  alias_method_chain :possible_values_options, :issue_custom_field_extension
    		end
    	end

    	module ClassMethods
    	end
    	
    	module InstanceMethods
          def possible_values_options_with_issue_custom_field_extension(obj=nil)
            begin
              if obj.respond_to?(:project) && obj.project
                if field_format == 'user'
                  custom_field_extension = issue_custom_field_extension
                  if !custom_field_extension.blank? and custom_field_extension.extends
                    return obj.project.principals.sort.collect {|u| [u.to_s, u.id.to_s]}
                  else
                    return possible_values_options_without_issue_custom_field_extension(obj)
                  end
                else
                  return possible_values_options_without_issue_custom_field_extension(obj)
                end
              else
                return possible_values_options_without_issue_custom_field_extension(obj)
              end
            rescue Exception => e
              Rails.logger.error "Plugin redmine_issue_custom_field_extension File:custom_field_patch.rb Strings:[] Error: #{e}"
              return possible_values_options_without_issue_custom_field_extension(obj)
            end
          end
    	end
    end
  end
end
