module RedmineIssueMailer
  module RedminePatch
	  module MailHandlerPatch
	    def self.included(base)
	      base.extend(ClassMethods)
	      base.send(:include, InstanceMethods)

	      base.class_eval do 
	        unloadable # Send unloadable so it will not be unloaded in development
	        alias_method_chain :receive_issue, :redmine_issue_mailer
	        alias_method_chain :receive_issue_reply, :redmine_issue_mailer
	      end
	    end

	    module ClassMethods
	    end
	    
	    module InstanceMethods
	      private
	        # Creates a new issue
		    def receive_issue_with_redmine_issue_mailer
		      issue = receive_issue_without_redmine_issue_mailer
		      begin
		      	handler_options = self.handler_options || {}
		     
			    if handler_options["redmine_issue_mailer_plugin"] == "1"
			      issue_reply_subject_re =  MailHandler.const_get(:ISSUE_REPLY_SUBJECT_RE)
			      m = email.subject.match(issue_reply_subject_re)
                  if issue.id != m.try(:[], 1).to_i
                  	email_from_client = issue.issue_email_from_clients.new()
                  	email_from_client.project_id = issue.project_id
			        email_from_client.message_id = email.message_id
			        email_from_client.from       = email.from.join(', ') 
			        email_from_client.to         = email.to.join(', ')
			        email_from_client.cc         = (email.cc || []).join(', ')
			        email_from_client.subject    = email.subject
			        unless email_from_client.save
			          messages = ""
                      messages = email_from_client.errors.full_messages.join(', ') if email_from_client.errors.any?
                      Rails.logger.error "issue_mailer_plugin Time:#{Time.now}  The following error occurred while save client inf: email from: #{email.from} email to: #{email.to} email message_id: #{email.message_id} Messages: #{messages}"
			        else
			          issue.description =  "{{view_information_about_letter(#{issue.id}, #{email_from_client.id}, #{issue.project_id}, #{'Issue'})}}" + "<pre>#{issue.description}</pre>"
			          issue.save
			        end
                  end
			    end
		      rescue Exception => e
                Rails.logger.error "issue_mailer_plugin Time:#{Time.now}  The following error occurred while works with issue:  #{e.backtrace}"
		      end
		      issue
		    end

			# Adds a note to an existing issue
			def receive_issue_reply_with_redmine_issue_mailer(issue_id, from_journal=nil)
              journal = receive_issue_reply_without_redmine_issue_mailer(issue_id, from_journal=nil)

              begin
              	handler_options = self.handler_options || {}
		        if handler_options["redmine_issue_mailer_plugin"] == "1"
		          email_from_client = IssueEmailFromClient.new()
		          email_from_client.journal_id = journal.id
                  email_from_client.project_id = journal.issue.project_id
                  email_from_client.issue_id   = journal.issue.id
			      email_from_client.message_id = email.message_id
			      email_from_client.from       = email.from.join(', ') 
			      email_from_client.to         = email.to.join(', ')
			      email_from_client.cc         = (email.cc || []).join(', ')
			      email_from_client.subject    = email.subject

			      unless email_from_client.save
			        messages = ""
                    messages = email_from_client.errors.full_messages.join(', ') if email_from_client.errors.any?
                    Rails.logger.error "issue_mailer_plugin Time:#{Time.now}  The following error occurred while save client inf: email from: #{email.from} email to: #{email.to} email message_id: #{email.message_id} Messages: #{messages}"
			      else
			      	journal.notes = "{{view_information_about_letter(#{journal.id}, #{email_from_client.id}, #{journal.issue.project_id}, #{'Journal'})}}" + "<pre>#{journal.notes}</pre>"
                    journal.save
			      end
		        end
              rescue Exception => e
                Rails.logger.error "issue_mailer_plugin Time:#{Time.now}  The following error occurred while works with journal:  #{e.backtrace}"
              end
		      journal
			end
	    end

	  end
  end
end