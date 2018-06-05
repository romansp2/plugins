module RedmineIssueCustomFieldExtensionPatch
  module ControllerIssuesNewAfterSavePatchV24  
    class Hooks < Redmine::Hook::ViewListener
      def controller_issues_new_after_save(context = {})
      	begin
    	    users = context[:issue].notified_users_from_custom_fields_for_new_issue
          unless users.empty?
            users_mails = users.collect(&:mail)
          
            mail = Mailer.issue_add(context[:issue])
            mail.to = users_mails
            mail.bcc = users_mails
            mail.cc = []
            mail.deliver
          end
      	rescue Exception => e
      	  Rails.logger.error "Error plugin redmine_issue_custom_field_extension File:controller_issues_new_after_save_patch_v24.rb str:[] #{e}"	
      	end
        
      end
    end
  end
end

#call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})