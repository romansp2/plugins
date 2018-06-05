module CreateWatcherGroupWithIssuePatch
  class Hooks < Redmine::Hook::ViewListener
    def view_issues_form_details_bottom(context = {})
      begin
        if User.current.allowed_to?(:add_issue_watchers,  context[:project])
        	params = context[:controller].params
          group_ids = []
      
          if params.include?("groups_issue") and params["groups_issue"].include?("group_ids")
            group_ids << params["groups_issue"]["group_ids"]
          else
            group_ids << params[:group_id]
          end
          group_ids = group_ids.flatten.compact.uniq

          groups = []
          unless group_ids.empty?
            request = "#{Principal.table_name}.type='Group' AND #{Principal.table_name}.status=#{Principal::STATUS_ACTIVE}"
            request += " AND #{Principal.table_name}.id IN (?)"
            begin
              groups = context[:project].principals.where(request, group_ids).sorted.all
            rescue Exception => e
              Rails.logger.error "Error plugin redmine_create_watcher_group_with_issue (file - view_issues_form_details_bottom_hook.rb) Error:  #{e.message}" 
              groups = []
            end
          end
        	
        	group_ids = groups.map(&:id)
          locals = context
          locals[:groups]    = groups
          locals[:group_ids] = group_ids
          locals[:project]   = context[:project]
          locals[:issue]     = context[:issue]
          locals[:form]      = context[:form]
          context[:controller].send(:render_to_string, {partial: '/group_issue/add_watcher_group_to_issue_form', locals: locals})
        end
      rescue Exception => e
        Rails.logger.error "Error plugin redmine_create_watcher_group_with_issue (file - view_issues_form_details_bottom_hook.rb) Error:  #{e.message}" 
        ""
      end
    end
  end
end