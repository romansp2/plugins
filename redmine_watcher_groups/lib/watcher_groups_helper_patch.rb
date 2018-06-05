require_dependency 'watcher_groups_helper' 

module WatcherGroupsWatcherHelperPatch

    def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
        base.class_eval do
            #unloadable

            alias_method_chain :notified_watchers , :groups

            alias_method_chain :visible?, :watcher_groups_rate
        end
    end

    IssuesController.class_eval do
      helper :watcher_groups
      include WatcherGroupsHelper
    end     	


    Issue.class_eval do
    	include WatcherGroupsHelper
    	
    	def watcher_groups
        Group.joins("LEFT JOIN #{Watcher.table_name} ON watchers.watchable_type='#{self.class}' AND watchers.watchable_id=#{self.id}").where("#{Watcher.table_name}.user_id=users.id")
    	end
    	      	  
        # Returns an array of users that are proposed as watchers
        def addable_watcher_groups
          groups = self.project.principals.select{|p| p if p.type=='Group'}
          groups = groups.sort - self.watcher_groups
          if respond_to?(:visible?)
            groups.reject! {|group| !visible?(group)}
          end
          groups
        end

        # Adds group as a watcher
        def add_watcher_group(group)
          if !Watcher.where("watchable_type='#{self.class}' and watchable_id = #{self.id} and user_id = '#{group.id}'").exists?
            # insert directly into table to avoid user type checking
            Watcher.connection.execute("INSERT INTO `#{Watcher.table_name}` (`user_id`, `watchable_id`, `watchable_type`) VALUES (#{group.id}, #{self.id}, '#{self.class.name}')")
          end
        end

        # Removes user from the watchers list
        def remove_watcher_group(group)
          return nil unless group && group.is_a?(Group)
          Watcher.delete_all "watchable_type = '#{self.class}' AND watchable_id = #{self.id} AND user_id = #{group.id}"
        end

        # Adds/removes watcher
        def set_watcher_group(group, watching=true)
          watching ? add_watcher_group(group) : remove_watcher_group(group)
        end

        # Returns true if object is watched by +user+
        def watched_by_group?(group)
          !!(group && self.watcher_groups.detect {|gr| gr.id == group.id })
        end
    end
    

    module InstanceMethods

        def notified_watchers_with_groups
            notified = []

            users_from_groups = User.where(nil)
            users_from_groups = users_from_groups.joins("LEFT JOIN groups_users ON users.id=groups_users.user_id")
            users_from_groups = users_from_groups.where("groups_users.group_id IN (?)", watcher_groups.pluck("users.id"))
            users_from_groups = users_from_groups.where("users.status = ?", User::STATUS_ACTIVE)
            #users_from_groups = users_from_groups.where("users.mail != '' AND users.mail IS NOT NULL")
            users_from_groups = users_from_groups.where("users.mail_notification != '' AND users.mail_notification IS NOT NULL")

            if respond_to?(:visible?)
              users_from_groups = users_from_groups.to_a.find_all{|user| visible?(user)} 
            end            
            notified += users_from_groups
            notified += notified_watchers_without_groups

            notified.uniq
        end


        def visible_with_watcher_groups_rate?(usr=nil)
          visible = visible_without_watcher_groups_rate?(usr)
          begin
            unless visible
              (usr || User.current).allowed_to?(:view_issues, self.project) do |role, user|
                if user.logged?
                  if role.issues_visibility == 'own'
                    user_included = User.joins("LEFT JOIN groups_users ON users.id=groups_users.user_id").where("groups_users.group_id IN (?)", watcher_groups.pluck("users.id")).where("users.id = ?", user.id).exists?
                    #if !watcher_groups.blank? and watcher_groups.any?{|group| group.users.include?(user)}
                    if user_included
                      visible = true
                    end
                  end
                end
              end
            end
          rescue Exception => e
            Rails.logger.error "Plugin redmine_watcher_groups File:watcher_groups_helper_patch.rb Strings:[100-110] Error: #{e}"
          end 
          visible
        end
    end

    module ClassMethods
    end
end


