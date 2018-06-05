module RedmineIssueMailer
  module RedmineHook
    class Hooks < Redmine::Hook::ViewListener
      def controller_issues_edit_before_save(context = {})
      	#begin
      	  #issue   = context[:issue]
      	  #project = issue.project
      	  #params  = context[:params]

      	  #if project.enabled_module_names.include?("issue_mailer") && params.include?("send_letter")
      	  #	 journal = context[:journal]
          #   mail_server_sett = project.issue_mail_server_settings.where("id = ?", params["send_letter"]["from"]).first
          #   unless true#mail_server_sett.nil?    
          #     journal.notes = "<b>Letter</b> <pre id='letter'>From: #{mail_server_sett.user_name} To: #{params["send_letter"]["to"]} \n\n Subject: #{params["send_letter"]["subject"]} \n\n Blind carbon copy: #{params["send_letter"]["bcc"]} \n\n Body: \n\n #{params["send_letter"]["body_txt"]}</pre> <br>" + journal.notes
          #   else
          #     journal.notes = "<p><b>Letter</b></p> <p><b>Error: Can not find From. See project settings</b></p> <pre id='letter'>From: #{mail_server_sett.user_name} To: #{params["send_letter"]["to"]} \n\n Subject: #{params["send_letter"]["subject"]} \n\n Blind carbon copy: #{params["send_letter"]["bcc"]} \n\n Body: \n\n #{params["send_letter"]["body_txt"]}</pre> <br>" + journal.notes
          #   end
          #end
      	#rescue Exception => e
      	 #Rails.logger.error "redmine_issue_mailer redmine_issue_mailer_loggerID#{Time.now.to_i} #{e}"
      	#end
      end
    end
  end
#call_hook(:controller_issues_edit_before_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
end