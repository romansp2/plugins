module CreateWatcherGroupWithIssuePatch
  class Hooks < Redmine::Hook::ViewListener
    def controller_issues_new_after_save(context = {})
      begin
        if User.current.allowed_to?(:add_issue_watchers,  context[:project])
        	group_ids = []
        	groups_issue = context[:params][:groups_issue]
          if groups_issue.is_a?(Hash)
            group_ids << groups_issue[:group_ids] 
          end
          issue = context[:issue]
         Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" 
          groups = []
          group_ids = group_ids.flatten.compact.uniq
          unless group_ids.empty?
            request = "#{Principal.table_name}.type='Group' AND #{Principal.table_name}.status=#{Principal::STATUS_ACTIVE}"
            request += " AND #{Principal.table_name}.id IN (?)" 
            groups = context[:project].principals.where(request, group_ids).sorted
          end

          groups.each do |group|
            group_id = group.id
            
            if !Watcher.where("watchable_type='#{issue.class}' and watchable_id = #{issue.id} and user_id = '#{group_id}'",).exists? 
              # insert directly into table to avoit user type checking
              Watcher.connection.execute("INSERT INTO `#{Watcher.table_name}` (`user_id`, `watchable_id`, `watchable_type`) VALUES (#{group_id}, #{issue.id}, '#{issue.class.name}')")
            end
          end
        end

      rescue Exception => e
        Rails.logger.error "Error plugin redmine_create_watcher_group_with_issue (file - controller_issues_new_after_save_hook.rb) Error:  #{e.message}" 
      end
    end
  end
end
