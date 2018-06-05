module Redmine
  module IssueCustomFieldExtensionPatch
    module FieldFormatPatch
    	
    	def self.included(receiver)
    	  receiver.extend         ClassMethods
    	  receiver.send :include, InstanceMethods

    	  receiver.class_eval do 
    	  	unloadable
            alias_method_chain :possible_values_options, :issue_custom_field_extension_patch
    	  end
    	end

    	module ClassMethods
    	end

    	module InstanceMethods

    	  def possible_values_options_with_issue_custom_field_extension_patch(custom_field, object=nil)
            #possible_values_options_without_issue_custom_field_extension_patch(custom_field, object)
            begin
              if custom_field.field_format == 'user' and custom_field.type == 'IssueCustomField'
                custom_field_extension = custom_field.issue_custom_field_extension
	              if !custom_field_extension.blank? and custom_field_extension.extends
	                if object.is_a?(Array)
			          projects = object.map {|o| o.respond_to?(:project) ? o.project : nil}.compact.uniq
			          projects.map {|project| possible_values_options(custom_field, project)}.reduce(:&) || []
			        elsif object.respond_to?(:project) && object.project
			          users = []
			          role_ids = []
			          project = object.project
			          if custom_field.user_role.is_a?(Array)
			            role_ids = custom_field.user_role.map(&:to_s).reject(&:blank?).map(&:to_i)
			          end
			          if role_ids.blank?
	                    users = Principal.active.where("id IN (?)", Member.where("members.project_id = ? ", project.id).pluck(:user_id).uniq).sorted.collect{|m| [m.to_s, m.id.to_s]}
			          else
	                    users = Principal.active.where("id IN (?)", Member.where("members.project_id = ? AND members.id IN (SELECT DISTINCT member_id FROM #{MemberRole.table_name} WHERE role_id IN (#{role_ids.join(',')}))", project.id).pluck(:user_id).uniq).sorted.collect{|m| [m.to_s, m.id.to_s]}
			          end
			          return users
			        else
			          users = []
			          role_ids = []
                      project_ids = Project.visible.pluck(:id)
			          if custom_field.user_role.is_a?(Array)
			            role_ids = custom_field.user_role.map(&:to_s).reject(&:blank?).map(&:to_i)
			          end
			          if role_ids.blank?
	                    users = Principal.active.where("id IN (?)", Member.where("members.project_id IN (?) ", project_ids).pluck(:user_id).uniq).sorted.collect{|m| [m.to_s, m.id.to_s]}
			          else
	                    users = Principal.active.where("id IN (?)", Member.where("members.project_id IN (?) AND members.id IN (SELECT DISTINCT member_id FROM #{MemberRole.table_name} WHERE role_id IN (#{role_ids.join(',')}))", project_ids).pluck(:user_id).uniq).sorted.collect{|m| [m.to_s, m.id.to_s]}
			          end
			    
			          return users
			        end
	              else
	              	return possible_values_options_without_issue_custom_field_extension_patch(custom_field, object)
	              end
	          end
	          return possible_values_options_without_issue_custom_field_extension_patch(custom_field, object)
            rescue Exception => e
              Rails.logger.error "Error plugin redmine_issue_custom_field_extension File:field_format_patch.rb str:[21-62] #{e}"
            end
            return possible_values_options_without_issue_custom_field_extension_patch(custom_field, object)
          end
    	end
    end
  end
end