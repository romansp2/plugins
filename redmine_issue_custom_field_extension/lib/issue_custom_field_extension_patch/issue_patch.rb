module Redmine
  module IssueCustomFieldExtensionPatch
    module IssuePatch
    	
    	def self.included(receiver)
    		receiver.extend         ClassMethods
    		receiver.send :include, InstanceMethods

    		receiver.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
    		  alias_method_chain :notified_users,  :issue_custom_field_extension
          alias_method_chain :visible?,        :issue_custom_field_extension

          #class << self
            #alias_method :origin_issue_custom_field_extension_visible_condition, :visible_condition
            #def visible_condition(user, options={})
            #  visible_condition = origin_issue_custom_field_extension_visible_condition(user, options)
            #  begin
            #    unless visible_condition.nil?
            #      Project.allowed_to_condition(user, :view_issues, options) do |role, user|
            #        # Keep the code DRY
            #        if [ 'own' ].include?(role.issues_visibility)
            #          custom_field_ids = IssueCustomFieldExtension.where("extends=1 AND visible=1").pluck(:custom_field_id)
            #          unless custom_field_ids.empty?
            #            user_ids = []
            #            user_ids << user.id
            #            group_ids = user.groups.pluck(:id)
            #            user_ids += group_ids
            #
            #            issue_responsible_clause = " OR #{table_name}.id IN ( SELECT custom_values.customized_id 
            #             FROM custom_values 
            #               WHERE custom_values.customized_type='Issue'
            #                  AND custom_values.custom_field_id IN (#{custom_field_ids.join(',')}) 
            #                  AND custom_values.value IN (#{user_ids.join(',')}) )"
            #            if user.logged?
            #              visible_condition << issue_responsible_clause
            #            end
            #          end
            #        end              
            #      end
            #    end
            #  rescue Exception => e
            #    Rails.logger.error "Plugin redmine_issue_custom_field_extension File:issue_patch.rb Strings:[] Error: #{e}"
            #  end
            #  visible_condition
            #end
          #end
        end
    	end

    	module ClassMethods
    	end
    	
    	module InstanceMethods
        def notified_users_with_issue_custom_field_extension
          notified = []
          custom_notified = []
          begin
            custom_field_ids = IssueCustomFieldExtension.where("extends=true AND notify=true").pluck(:custom_field_id)
            (return notified_users_without_issue_custom_field_extension) if custom_field_ids.empty?
            custom_value_user_ids = CustomValue.where("custom_values.customized_type='Issue' 
                               AND custom_values.customized_id=#{self.id}
                               AND custom_values.value != '' 
                               AND custom_values.value IS NOT NULL
                               AND custom_values.custom_field_id IN (#{custom_field_ids.join(',')})").pluck(:id)
            #custom_value_user_ids = custom_values.map(&:value).delete_if {|custom_value| custom_value.nil? or custom_value.empty? }
            (return notified_users_without_issue_custom_field_extension) if custom_value_user_ids.empty?
            users = []
            users += User.where("id IN (#{custom_value_user_ids.join(',')})")
            #groups = Group.where("id IN (#{custom_value_user_ids.join(',')})")
            group_users = User.joins("INNER JOIN groups_users ON users.id = groups_users.user_id AND groups_users.group_id IN (#{custom_value_user_ids.join(',')})").uniq
            users += group_users
            #groups.each do |group|
              #users += group.users
            #end
            custom_notified << users.uniq
            custom_notified << notified_users_without_issue_custom_field_extension
            notified = custom_notified.flatten.uniq.select {|u| u.active?}
          rescue Exception => e
            Rails.logger.error "Plugin redmine_issue_custom_field_extension File:issue_patch.rb Strings:[60-79] Error: #{e}"
            notified = notified_users_without_issue_custom_field_extension
          end
          notified
        end

        def notified_users_from_custom_fields_for_new_issue
          notified = []
          custom_notified = []
          begin
            custom_field_ids = IssueCustomFieldExtension.where("extends=true AND notify=true").pluck(:custom_field_id)
        
            (return []) if custom_field_ids.empty?
            custom_value_user_ids = CustomValue.where("custom_values.customized_type='Issue' 
                                      AND custom_values.customized_id=#{self.id}
                                      AND custom_values.value != '' 
                                      AND custom_values.value IS NOT NULL
                                      AND custom_values.custom_field_id IN (#{custom_field_ids.join(',')})").pluck(:value)
     
            (return []) if custom_value_user_ids.empty?

            users = []
            users += User.where("id IN (#{custom_value_user_ids.join(',')})")
            groups = Group.where("id IN (#{custom_value_user_ids.join(',')})")


            user_that_assigned_to = self.assigned_to
            author_of_issue       = self.author
            watchers_of_issue     = self.watchers.pluck("user_id")

            groups.each do |group|
              if group != user_that_assigned_to and !(watchers_of_issue.include?(group.id))
                users += group.users
              end
            end
            custom_notified += users.uniq

            notified = custom_notified.flatten.uniq.select {|u| (u.active? and u != author_of_issue and u != user_that_assigned_to and !(watchers_of_issue.include?(u.id)) and u.notify_about?(self) )}
          rescue Exception => e
            Rails.logger.error "Plugin redmine_issue_custom_field_extension File:issue_patch.rb Strings:[] Error: #{e}"
            notified = []
          end
          return notified
        end


        def visible_with_issue_custom_field_extension?(usr=nil)
          visible = visible_without_issue_custom_field_extension?(usr)
          begin
            unless visible
              (usr || User.current).allowed_to?(:view_issues, self.project) do |role, user|
                if user.logged?
                  if role.issues_visibility == 'own'
                    custom_value_visible = false
                    custom_field_ids = IssueCustomFieldExtension.where("extends=1 AND visible=1").pluck(:custom_field_id)
                    (return false) if custom_field_ids.empty?
                    group_ids = []
                    user_ids = []
                    user_ids << user.id
                  
                    member_group_ids = project.principals.where("users.type='Group'").pluck(:id)
                    user_group_ids = user.groups.pluck(:id)
                    
                    group_ids = (member_group_ids & user_group_ids)
                    user_ids += group_ids
              
                    unless group_ids.empty?
                      custom_value_visible = CustomValue.where("custom_values.customized_type='Issue' 
                                                        AND custom_values.customized_id=#{self.id} 
                                                        AND custom_values.custom_field_id IN (#{custom_field_ids.join(',')}) 
                                                        AND custom_values.value IN (#{user_ids.join(',')})").exists?
                    else
                      custom_value_visible = CustomValue.where("custom_values.customized_type='Issue' 
                                                        AND custom_values.customized_id=#{self.id} 
                                                        AND custom_values.custom_field_id IN (#{custom_field_ids.join(',')}) 
                                                        AND custom_values.value=#{user.id}").exists?
                    end

                    visible = custom_value_visible
                  end
                end
              end
            end 
          rescue Exception => e
            Rails.logger.error "Plugin redmine_issue_custom_field_extension File:issue_patch.rb Strings:[78-88] Error: #{e}"
          end
          visible
        end
    	end
    	
    end
  end
end
