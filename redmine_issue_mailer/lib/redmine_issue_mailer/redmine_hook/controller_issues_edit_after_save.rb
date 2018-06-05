module RedmineIssueMailer
  module RedmineHook
    class Hooks < Redmine::Hook::ViewListener
      def redmine_issue_mailer_parse_receiver(params, issue, project)
        #check permission email receiver
        permission_errors = ""
        to  = ""
        bcc = ""
        cc  = ""
        if params["send_letter"].include?("permission_for_to")
          permission_for_to = params["send_letter"]["permission_for_to"]
          permission_errors = ""
          
          case permission_for_to
            when "1"
              if User.current.allowed_to?(:write_letter_to_client, project)
                first_letter_from_client = issue.issue_email_from_clients.first
                if first_letter_from_client.nil?
                  permission_errors = "Application did not find client email"#Maybe issue was not created from letter"
                else
                  to = first_letter_from_client.from
                  bcc = ""
                  cc  = ""
                end
              else
                permission_errors = "You do not have permission write to client"
              end
            when "2"
              if User.current.allowed_to?(:write_letter_to_email_from_book_of_e_mail_address, project)
                if params["send_letter"].include?("email_books_to")
                  email_books = project.email_books.where("email_books.id IN (?)", params["send_letter"]["email_books_to"]).pluck(:email)
                  to  = email_books.join(', ').gsub(/\s+/, '').downcase
                  bcc = ""
                  cc  = ""

                  permission_errors = "could not find selected recipients" if to.empty?
                else
                  permission_errors = "You did not select recipients"
                end
              else
                permission_errors = "You do not have permission write to emails from book"
              end
            when "3"
              if User.current.allowed_to?(:write_letter_without_restriction, project)
                to   = params["send_letter"]["to"].gsub(/\s+/, '').downcase #.split(',')
                bcc  = params["send_letter"]["bcc"].gsub(/\s+/, '').downcase
                cc   = ""
              else
                permission_errors = "You do not have permission write without restriction"
              end
            else 
              permission_errors = "Can not recognize permission"
          end
        else
          permission_errors = "Can not recognize permission"
        end
        [to, bcc, cc, permission_errors]
      end

      def controller_issues_edit_after_save(context = {})
        begin
      	  issue    = context[:issue]
      	  project = issue.project
      	  params  = context[:params]
      	  if project.enabled_module_names.include?("issue_mailer") && params.include?("send_letter") && User.current.allowed_to?(:write_letter_to_clients, project)
      	  	 journal = context[:journal]
             mail_server_sett = project.issue_mail_server_settings.where("id = ?", params["send_letter"]["from"]).first
             unless mail_server_sett.nil?    
               
               issue_sent_on_client_email = IssueSentOnClientEmail.new
               issue_sent_on_client_email.journal = journal
               issue_sent_on_client_email.project = project
               issue_sent_on_client_email.issue_id   = issue.id
               
               issue_sent_on_client_email.from = mail_server_sett.user_name

               #
               to, bcc, cc, permission_errors = redmine_issue_mailer_parse_receiver(params, issue, project)

               unless permission_errors.blank?
                 journal.notes = <<-EOF 
                     <p><b>#{l(:letter, scope: [:redmine_issue_mailer])}</b></p> 
                     <p style='color:red'><b>#{l(:error_send_letter, scope: [:redmine_issue_mailer])}: #{permission_errors}</b></p> 
                     <br>
                     <pre id='letter'> 
                       <p>#{l(:letter_subject, scope: [:redmine_issue_mailer])}: #{h params["send_letter"]["subject"]} </p>
                       <p>#{l(:letter_body_txt, scope: [:redmine_issue_mailer])}: 
                         #{h params["send_letter"]["body_txt"]} 
                       </p>
                       <p>#{l(:letter_attached, scope: [:redmine_issue_mailer])}: #{!params["send_letter"]["attachments"].blank?}</p>
                     </pre> <br>

                     #{journal.notes}
                 EOF
                 journal.save
               
                 return
               end#unless permission_errors.blank?
               issue_sent_on_client_email.to   = to 
               issue_sent_on_client_email.bcc  = bcc
               issue_sent_on_client_email.cc   = cc
               #

               #issue_sent_on_client_email.to   = params["send_letter"]["to"].gsub(/\s+/, '').downcase #.split(',')
               #issue_sent_on_client_email.bcc  = params["send_letter"]["bcc"].gsub(/\s+/, '').downcase
               #issue_sent_on_client_email.cc   = ""
               

               

               issue_sent_on_client_email.subject = "#{params["send_letter"]["subject"]} [##{issue.id}]"
               issue_sent_on_client_email.body    = params["send_letter"]["body_txt"]
               issue_email_footer = nil
               if params["send_letter"].include?("footer_id")
                  issue_email_footer = project.issue_email_footers.where("issue_email_footers.id = ?", params["send_letter"]["footer_id"]).first
                  unless issue_email_footer.nil?
                    issue_sent_on_client_email.body += issue_email_footer.footer
                  end
               end


               issue_sent_on_client_email.attachments = params["send_letter"]["attachments"]
               if issue_sent_on_client_email.save
                 #journal.notes = "#{"{{view_information_about_sent_letter(#{journal.id}, #{issue_sent_on_client_email.id}, #{issue.project_id}, #{'Journal'})}}"} <br> <b>Letter</b> <pre id='letter_#{issue_sent_on_client_email}' journal_id='#{journal.id}'> Subject: #{params["send_letter"]["subject"]} ##{issue.id} \n\n Body: \n\n #{issue_sent_on_client_email.body }</pre> <br>" + journal.notes
                 journal.notes = <<-EOF 
                   {{view_information_about_sent_letter(#{journal.id}, #{issue_sent_on_client_email.id}, #{issue.project_id}, #{'Journal'})}}
                   <br> 
                   <b>#{l(:letter, scope: [:redmine_issue_mailer])}</b> 
                   <pre id='letter_#{issue_sent_on_client_email.id}' journal_id='#{journal.id}'> 
                     <b>#{l(:letter_subject, scope: [:redmine_issue_mailer])}:</b> #{h issue_sent_on_client_email.subject}
                     <b>#{l(:letter_body_txt, scope: [:redmine_issue_mailer])}:</b> 
                       #{h issue_sent_on_client_email.body }
                     <b>#{l(:letter_attached, scope: [:redmine_issue_mailer])}:</b> #{issue_sent_on_client_email.attachments == true}
                   </pre>
                   <br>
                   #{journal.notes}
                 EOF
                 
                 journal.save

                 MailerIssueClient.send_to_client(issue_sent_on_client_email).deliver 

               else
                 errors = issue_sent_on_client_email.errors.values.flatten.join(', ')

                 journal.notes = <<-EOF 
                   <p><b>#{l(:letter, scope: [:redmine_issue_mailer])}</b></p> 
                   <p style='color:red'><b>#{l(:error_send_letter, scope: [:redmine_issue_mailer])}: #{errors}</b></p> 
                   <br>
                   <pre id='letter'> 
                     <p>#{l(:letter_subject, scope: [:redmine_issue_mailer])}: #{h params["send_letter"]["subject"]} </p>
                     <p>#{l(:letter_body_txt, scope: [:redmine_issue_mailer])}: 
                       #{h (params["send_letter"]["body_txt"] + "#{issue_email_footer.try(:footer)}") }
                     </p>
                     #{l(:letter_attached, scope: [:redmine_issue_mailer])}: #{!params["send_letter"]["attachments"].blank?}
                   </pre> <br>

                   #{journal.notes}
                 EOF

                 journal.save
               end
             else
               errors = l(:check_settings, scope: [:redmine_issue_mailer])
               journal.notes = <<-EOF 
                 <p><b>#{l(:letter, scope: [:redmine_issue_mailer])}</b></p> 
                 <p style='color:red'><b>#{l(:error_send_letter, scope: [:redmine_issue_mailer])}: #{errors}</b></p> 
                 <br>
                 <pre id='letter'> 
                   <p>#{l(:letter_subject, scope: [:redmine_issue_mailer])}: #{h params["send_letter"]["subject"]} </p>
                   <p>#{l(:letter_body_txt, scope: [:redmine_issue_mailer])}: 
                     #{h params["send_letter"]["body_txt"]}
                   </p> 
                   <p>#{l(:letter_attached, scope: [:redmine_issue_mailer])}: #{!params["send_letter"]["attachments"].blank?}</p>
                 </pre> <br>

                 #{journal.notes}
               EOF

               journal.save
             end
          end
      	rescue Exception => e
      	  Rails.logger.error "redmine_issue_mailer redmine_issue_mailer_loggerID#{Time.now.to_i} #{e}"
      	end
      end
    end
  end 
#call_hook(:controller_issues_edit_after_save, { :params => params, :issue => @issue, :time_entry => time_entry, :journal => @issue.current_journal})
end
