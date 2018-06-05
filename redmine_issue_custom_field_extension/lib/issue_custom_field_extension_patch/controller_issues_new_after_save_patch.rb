module RedmineIssueCustomFieldExtensionPatch
  module ControllerIssuesNewAfterSavePatch
    class Hooks < Redmine::Hook::ViewListener
      def controller_issues_new_after_save(context = {})
      	begin
          if context[:issue].notify? and Setting.notified_events.include?('issue_added')
            if Setting.plugin_redmine_issue_custom_field_extension["use_sidekiq"] == "true"
              IssueCustomFieldExtensionMailerIssueAddWorker.perform_async(context[:issue].to_json)
            else
      	      users = context[:issue].notified_users_from_custom_fields_for_new_issue
              unless users.empty?
                Mailer.issue_add(context[:issue], users, []).deliver
              end
            end
      	  end
        rescue Exception => e
      	  Rails.logger.error "Error plugin redmine_issue_custom_field_extension File:controller_issues_new_after_save_patch.rb str:[] #{e}"	
      	end
      end
    end
  end
end

#call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})