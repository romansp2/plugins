require_dependency 'query'

module Redmine
  module IssueCustomFieldExtensionPatch
    module IssueQueryPatch
    	
    	def self.included(receiver)
    		receiver.extend         ClassMethods
    		receiver.send :include, InstanceMethods
            
            receiver.class_eval do
    		      unloadable
              #alias_method_chain :available_columns, :issue_custom_field_extension
              alias_method_chain :available_filters, :issue_custom_field_extension
            end
    	end

    	module ClassMethods
    	end
    	
    	module InstanceMethods
    	  
    	  def available_filters_with_issue_custom_field_extension
    	  	begin
    	  	  if @available_filters.blank? and project.blank?
	            user_custom_values_list = issue_custom_field_extension_select
	            custom_fiels = CustomField.where("type='IssueCustomField' AND field_format='user'")
	            to_available_filter = {}
	            custom_fiels.each do |custom_field|
	              to_available_filter.merge!( { "cf_#{custom_field.id}" => { :type => :list, :name => "#{custom_field.name}", :order  => 6, :values => user_custom_values_list} })
	            end
	            available_filters_without_issue_custom_field_extension.merge!(to_available_filter) if User.current.allowed_to?(:view_issues, project, :global => true)
	          else
	            available_filters_without_issue_custom_field_extension
	          end
	          
	        rescue Exception => e
            Rails.logger.error "Error plugin redmine_issue_custom_field_extension File:issue_query_patch.rb str:[28-39] #{e}"
	          available_filters_without_issue_custom_field_extension
    	  	end
    	  	@available_filters
        end
    	end

        def issue_custom_field_extension_select
            unless project
              project_ids = Project.visible.pluck(:id)
              #users = Principal.where("id IN (?)", Member.includes(:principal).where("members.project_id IN (?)", projects.map(&:id)).map(&:user_id).uniq).collect{|m| [m.name, m.id.to_s]}
              users = Principal.where("#{Principal.table_name}.type='Group' OR (#{Principal.table_name}.type='User' AND #{Principal.table_name}.status=#{Principal::STATUS_ACTIVE})").joins("LEFT JOIN members ON members.project_id IN (#{Project.visible.pluck(:id).join(', ')}) AND users.id = members.user_id").uniq.sort.collect!{|m| [m.name, m.id.to_s]}
              return users
            end
          rescue
            []
        end
    	
    end
  end
end