module RedmineIssueMailer
  module RedminePatch
    module  MailHandlerControllerPatch
      def self.included(base) # :nodoc:
    	base.extend(ClassMethods)
    	base.send(:include, InstanceMethods)
        # Same as typing in the class
    	  base.class_eval do
      	  unloadable # Send unloadable so it will not be unloaded in development
          before_filter :redmine_issue_mailer_plugin, only: [:index]
          #after_filter :after_f
    	  end
      end

      module ClassMethods
      end

      module InstanceMethods
        private
          def redmine_issue_mailer_plugin
            #https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/base.rb#L526
            ##  subject.match(\[[^\]]*#(\d+)\])
            ##  subject.match(\[(title)[ \t]*:\s*(\D*)\])
            ##  \[(title)[ \t]*:\s*([\D\d]*)\]
            ## select email \[(email)[ \t]*:\s*(\D*)\]
            ## validate email  /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
            ## "kkjjuser@jjjj.com".match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i).nil?
            ##        
            begin
              if params.include?(:email) && !params[:email].blank? && params.try(:[], "issue").try(:[], "project").blank?
                mail = MailerIssueClient.receive(params[:email])
                froms = mail.from.to_a
                tos   = mail.to.to_a
                subject = mail.subject
                tos_clear   = []
                froms_clear = []

                
                froms.each do |from|
                  from_reg = from.match(/<(.+@.+)>/)
                  from_str = ""
                  unless from_reg.nil?
                    from_str = from_reg[1] 
                  else
                    from_reg = from.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
                    from_str = from_reg[1]+"@"+from_reg[2]
                  end
                  froms_clear << from_str
                end
                tos.each do |to|
                  to_reg   = to.match(/<(.+@.+)>/)
                  unless to_reg.nil?
                    to_str = to_reg[1] 
                  else
                    to_reg = to.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
                    to_str = to_reg[1]+"@"+to_reg[2]
                  end
                  tos_clear << to_str
                end

                #Check undelivered mail
                mailer_daemon = (Setting.plugin_redmine_issue_mailer['mailer_daemon'] || "").split(',')
                unless (froms_clear & mailer_daemon).blank?
                  parse_undelivered_email(mail, froms_clear, tos_clear, mailer_daemon )
                  #params["email"] = ""
                  return
                end

                #sent letter to yourself ('to' include mail from 'from')
                froms_tos_intersection = froms_clear & tos_clear
                unless froms_tos_intersection.empty?
                  message = IssueSentOnClientEmail.where("message_id = ? ", "#{mail.message_id}").first
                  message.try(:deliver=, true)
                  message.try(:save)
                  params["email"].replace("")
                  return
                end
                #
                message_id = mail.message_id
                issue_mail_serv_sett = nil
                sent_message = nil
                froms_clear.each do |from|
                  issue_mail_serv_sett = IssueMailServerSetting.find_by_user_name(from)
                  unless issue_mail_serv_sett.nil?
                    sent_message = IssueSentOnClientEmail.where("`from` LIKE(?) AND message_id = ? ", "%#{issue_mail_serv_sett.user_name}%", "#{message_id}").first
                    (break) unless sent_message.nil?
                  end
                end
                if !sent_message.nil? and !issue_mail_serv_sett.nil?
                  sent_message.deliver = true
                  sent_message.save
                  params["email"].replace("")
                  return
                end
                #
                issue_mail_serv_sett = nil
                tos_clear.each do |to|
                  issue_mail_serv_sett = IssueMailServerSetting.find_by_user_name(to)
                  (break) unless issue_mail_serv_sett.nil?
                end
                project = issue_mail_serv_sett.try(:project)
                if !project.nil?
                  standard_field = project.issue_mailer_standard_field
                  params["redmine_issue_mailer_plugin"] = "1"
                  #"issue"=>{"project"=>"", "status"=>"", "tracker"=>"", "category"=>"", "priority"=>""}
                  params["issue"]["project"] = project.identifier
                  #params["issue"]["status"]  = ""
                  #params["issue"]["tracker"] = ""
                  params["issue"]["assigned_to"] = standard_field.try(:assigned_to).try(:email_address).try(:address)
                  #params["issue"]["priority"] = ""

                  #params["issue"]["assigned_to"] = "jsmith@somenet.foo"
                  custom_field_values = project.issue_mailer_custom_field_value || project.build_issue_mailer_custom_field_value

                  custom_field_ids = custom_field_values.value.try(:keys) || []
                  custom_fields = []
              
                  custom_fields = CustomField.where("id IN (?)", custom_field_ids) unless custom_field_ids.empty?

                  custom_fields.each do |custom_field|
                    value = custom_field_values.value["#{custom_field.id}"]

                    if custom_field.field_format == 'user' 
                      if value.is_a?(Array)
                        value = User.find_by_id(value.first).try(:name) 
                      else
                        value = User.find_by_id(value).try(:name) unless value.is_a?(Array)
                      end
                    end
                    
                    params["issue"]["#{custom_field.name}"] = value
                  end
                  #params["issue"]["Searchable field"] = 'Hello'
                else 
                  #parse from. Check if from exist in IssueMailServerSetting
                  #If exist in IssueMailServerSetting then check if exist message_id in IssueSentOnClientEmail
                  #confirm that email deliver 
                  issue_mail_serv_sett = nil
                  froms_clear.each do |from|
                    issue_mail_serv_sett = IssueMailServerSetting.find_by_user_name(from)
                    (break) unless issue_mail_serv_sett.nil?
                  end
                  unless issue_mail_serv_sett.nil?
                    #Не может найти исходящего сообщения 
                    #Это может быть письмо отправленное непосредственно из почтового ящика, а не из redmine-а
                    project = issue_mail_serv_sett.project
                    if !project.nil?
                      params["redmine_issue_mailer_plugin"] = "1"
                      #"issue"=>{"project"=>"", "status"=>"", "tracker"=>"", "category"=>"", "priority"=>""}
                      params["issue"]["project"] = project.identifier
                      #params["issue"]["status"]  = ""
                      #params["issue"]["tracker"] = ""
                      #params["issue"]["assigned_to"] = ""
                      #params["issue"]["priority"] = ""
                    end#if !project.nil?
                  end#unless issue_mail_serv_sett.nil?
                end#!project.nil?
              end
            rescue Exception => e 
              Rails.logger.error "redmine_issue_mailer_plugin #{Time.now}  Message: #{e.backtrace} \n"  
            end
          end# def change_params


          def parse_undelivered_email(mail, froms_clear, tos_clear, mailer_daemon )
            #Check undelivered mail
            #treat undelivered mail
            #Undelivered Message
            #mail.body.decoded().match(/Message-ID:\s<(redmine.*)>/i)[1]
            message_id = mail.raw_source.match(/Message-ID:\s<(redmine.*)>/i)[1]
            issue_mail_serv_sett = nil
            sent_message = nil
            tos_clear.each do |to|
              issue_mail_serv_sett = IssueMailServerSetting.find_by_user_name(to)
              unless issue_mail_serv_sett.nil?
                sent_message = IssueSentOnClientEmail.where("`from` = ? AND message_id = ? ", "#{issue_mail_serv_sett.user_name}", "#{message_id}").first
                (break) unless sent_message.nil?
              end
            end
            (return) if sent_message.nil?

            sent_messag_id = mail.raw_source.match(/Message-ID:\s<(redmine.*)>/i)[1]

            #sent_message = IssueSentOnClientEmail.where("message_id = ? ", "#{sent_messag_id}").first
            

            sent_message_tos = sent_message.to.split(",")
            #mail.body.decoded().scan(/(.*@.*)/i).flatten.map{|m| m.gsub(/\s/, '').downcase}.uniq & []
            #mail.raw_source.scan(/(.*@.*)/i).flatten.map{|m| m.gsub(/\s/, '').downcase}.uniq & []

            #mail.raw_source.scan(Regexp.new("<(.*@.*)>", true)).flatten.map{|m| m.gsub(/\s/, '').downcase}.uniq

            regexp_scan = Hash[(Setting.plugin_redmine_issue_mailer["regexp_scan"]|| "").split(",").collect{|x| x.strip.split("=>/")}]
            mail_domain = mail.from.first.match(/@(.*)/)[1]

            perhaps_undelivered = []
            if regexp_scan.include?(mail_domain)
              regexpr = Regexp.new(regexp_scan[mail_domain], true)
              emails = mail.raw_source.scan(regexpr).flatten.map{|m| m.gsub(/\s/, '').downcase}.uniq
              perhaps_undelivered = emails & sent_message_tos.map{|m| m.gsub(/\s/, '').downcase}.uniq
            end
            #
            if perhaps_undelivered.empty?
              set_undelivered_for_emails(mail, sent_message, sent_message_tos)
            else
              set_undelivered_for_emails(mail, sent_message, perhaps_undelivered)
            end

          end#def check_undelivered_email

          def set_undelivered_for_emails(mail, sent_message, sent_message_tos)
            sent_message_tos.each_with_index do |email, index|
              undelivered_message = sent_message.undelivered_messages.new
              undelivered_message.to_original_recipient = email
              undelivered_message.message_report_id  = mail.message_id
              undelivered_message.note = "maybe undelivered"
              undelivered_message.save
            end
          end
      end
    end
  end
end