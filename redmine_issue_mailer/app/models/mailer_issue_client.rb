class MailerIssueClient < ActionMailer::Base
  layout 'mailer'
  helper :application
  #include AbstractController::Callbacks
  include Redmine::I18n

 # after_filter :set_business_headers
  def receive(email)
    email.force_encoding('ASCII-8BIT') if email.respond_to?(:force_encoding)
    email
  end

  def send_to_client(mail_client)
    set_language_if_valid(@initial_language) unless @initial_language.nil? 

    project = mail_client.project
    journal = mail_client.journal

    mailer_smtp = project.issue_mail_server_settings.first
    
    from = mail_client.from
    @mail_from = from
    to   = mail_client.to.split(',').uniq
    bcc  =  [mail_client.from] 
    bcc  += mail_client.bcc.split(',').uniq
    cc   = mail_client.cc.split(',').uniq
    subject = mail_client.subject
    body    = mail_client.body 
    
    #redmine_headers 'Project' => project_identifier

   	delivery_options = { user_name: mailer_smtp.user_name,
                         password:  mailer_smtp.password,
                         address:   mailer_smtp.adress
                       }
    delivery_options[:port]           = mailer_smtp.port           unless mailer_smtp.port.blank?
    delivery_options[:domain]         = mailer_smtp.domain         unless mailer_smtp.domain.blank?
    delivery_options[:authentication] = mailer_smtp.authentication unless mailer_smtp.authentication.blank?
    
    delivery_options[:enable_starttls_auto] = mailer_smtp.enable_starttls_auto
    
    delivery_options[:openssl_verify_mode] = mailer_smtp.openssl_verify_mode unless mailer_smtp.openssl_verify_mode.blank?
    
    delivery_options[:ssl] = mailer_smtp.ssl
    delivery_options[:tls] = mailer_smtp.tls

    message_id = self.class.message_id_for(journal)
    redmine_headers({'X-Mailer' => 'Redmine',
                     'X-Redmine-Host' => Setting.host_name,
                     'X-Redmine-Site' => Setting.app_title,
                     'X-Redmine-Issue' => "#{mail_client.issue_id}",
                     'X-Auto-Response-Suppress' => 'OOF',
                     'Auto-Submitted' => 'auto-generated',
                     'From' => @mail_from,
                     'List-Id' => "<#{@mail_from.to_s.gsub('@', '.')}>"
                    })
#                     'message_id' => message_id
    mail_client.message_id = message_id
    #mail_client.deliver = true
    mail_client.save

    #attachments
    if mail_client.attachments
      journal = mail_client.journal
      journal_ids = journal.details.where("journal_details.property = 'attachment'").pluck(:prop_key)

      journal_attachments = Attachment.where("id IN (?)", journal_ids )
      unless journal_attachments.blank?
        journal_attachments.each do |journal_attachment|
          attachments[journal_attachment.filename] = File.read(journal_attachment.diskfile)
        end
      end
    end


    m = mail(:to => to,
              :from => from,
              :bcc  => bcc,
              :subject => subject,
              :body    => body
             )
    #mm.delivery_method.settings.merge!({ :address  => 'smtp.gmail.com', :port  => 587, :domain => 'gmail.com', :user_name => 'alekseykond1@gmail.com', :password => 'za3kl7mpeh', :authentication => 'plain', :enable_starttls_auto => true})
    #m.headers['Message-ID'] = message_id
    m.message_id = "<#{message_id}>"
    

    m.delivery_method.settings.merge!(delivery_options)
  end
  private
  #def message_id(object)
   # @message_id_object = object
  #end
    def self.token_for(object, rand=true)
      timestamp = object.send(object.respond_to?(:created_on) ? :created_on : :updated_on)
      hash = [
        "redmine",
        "#{object.class.name.demodulize.underscore}-#{object.id}",
        timestamp.strftime("%Y%m%d%H%M%S")
      ]
      if rand
        hash << Redmine::Utils.random_hex(8)
      end
      host = Setting.mail_from.to_s.strip.gsub(%r{^.*@|>}, '')
      host = "#{::Socket.gethostname}.redmine" if host.empty?
      "#{hash.join('.')}@#{host}"
    end

    # Returns a Message-Id for the given object
    def self.message_id_for(object)
      token_for(object, true)
    end
  
    #(Copy from Mailer) Appends a Redmine header field (name is prepended with 'X-Redmine-')
    def redmine_headers(h)
      h.each { |k,v| headers["X-Redmine-#{k}"] = v.to_s }
    end

end