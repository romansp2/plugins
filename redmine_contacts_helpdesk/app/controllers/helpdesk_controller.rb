class HelpdeskController < ApplicationController
  unloadable

  before_filter :find_project, :authorize, :except => [:email_note, :update_customer_email]

  accept_api_auth :email_note, :create_ticket

  def save_settings
    if request.put?
      set_settings
      flash[:notice] = l(:notice_successful_update)
    end

    redirect_to :controller => 'projects', :action => 'settings', :tab => params[:tab] || 'helpdesk', :id => @project
  end

  def show_original
    @attachment = Attachment.find(params[:id])
    email = Mail.read(@attachment.diskfile)
    part = email.text_part || email.html_part || email
    body_charset = Mail::RubyVer.pick_encoding(part.charset).to_s rescue part.charset
    plain_text_body = Redmine::CodesetUtil.to_utf8(part.body.decoded, body_charset)
    headers = email.header.fields.map{|f| "#{f.name}: #{Mail::Encodings.unquote_and_convert_to(f.value, 'utf-8')}"}.join("\n")
    @content = headers + "\n\n" + plain_text_body

    render "attachments/file"
  end

  def delete_spam
    if User.current.allowed_to?(:delete_issues, @project) && User.current.allowed_to?(:delete_contacts, @project)
      begin
        @issue = Issue.find(params[:issue_id])
        @customer = @issue.customer
      rescue ActiveRecord::RecordNotFound
        render_404
      end

      ActiveRecord::Base.transaction do
        ContactsSetting[:helpdesk_blacklist, @project.id] = (ContactsSetting[:helpdesk_blacklist, @project.id].split("\n") | [@issue.customer.primary_email.strip]).join("\n")
        @customer.tickets.map(&:destroy)
        @customer.destroy
      end

      respond_to do |format|
        format.html { redirect_back_or_default(:controller => 'issues', :action => 'index', :project_id => @project) }
        format.api  { render_api_ok }
      end

    else
      deny_access
    end
  end

  def email_note
    raise Exception, "Param 'message' should be set" unless params[:message]
    @issue = Issue.find(params[:message][:issue_id])

    raise Exception, "Issue with ID: #{params[:message][:issue_id].to_i} should be present and relate to customer" if @issue.nil? || @issue.customer.nil?


    @journal = @issue.init_journal(User.current)
    @issue.status_id = params[:message][:status_id] if params[:message][:status_id].blank? && IssueStatus.find_by_id(params[:message][:status_id])
    @journal.notes = params[:message][:content]
    @issue.save!

    contact = @issue.customer

    HelpdeskMailer.with_activated_perform_deliveries do
      if HelpdeskMailer.issue_response(contact, @journal, params).deliver

        @journal_message = JournalMessage.create(:from_address => "",
                                                :to_address => contact.primary_email.downcase,
                                                :is_incoming => false,
                                                :message_date => Time.now,
                                                :contact => contact,
                                                :journal => @journal)
      end
    end

    respond_to do |format|
      format.api { render :action => 'show', :status => :created }
    end

  rescue Exception => e
    respond_to do |format|
      format.api  do
        @error_messages = [e.message]
        render :template => 'common/error_messages.api', :status => :unprocessable_entity, :layout => nil
      end
    end
  end

  def create_ticket
    raise Exception, "Param 'ticket' should be set" if params[:ticket].blank?
    @issue = Issue.new
    @issue.project = @project
    @issue.author ||= User.current
    @issue.safe_attributes = params[:ticket][:issue]
    raise Exception, "Contact should have email address" unless params[:ticket][:contact] || params[:ticket][:contact][:email]

    @contact = Contact.find_by_emails([params[:ticket][:contact][:email]]).first
    @contact ||= Contact.new(params[:ticket][:contact])
    @contact.projects << @project

    helpdesk_ticket = HelpdeskTicket.new(:from_address => @contact.primary_email,
                                        :to_address => '',
                                        :ticket_date => Time.now,
                                        :customer => @contact,
                                        :is_incoming => true,
                                        :issue => @issue,
                                        :source => HelpdeskTicket::HELPDESK_WEB_SOURCE)

    @issue.helpdesk_ticket = helpdesk_ticket
    @issue.assigned_to = @contact.find_assigned_user(@project, @issue.assigned_to)
    @issue.save_attachments(params[:attachments] || (params[:ticket][:issue] && params[:ticket][:issue][:uploads]))
    if @issue.save
      HelpdeskMailer.auto_answer(@contact, @issue).deliver if HelpdeskSettings[:helpdesk_send_notification, @project].to_i > 0

      respond_to do |format|
        format.api  { redirect_on_create(params) }
      end
    else
      raise Exception, "Can't create issue: #{@issue.errors.full_messages}"
    end

  rescue Exception => e
    respond_to do |format|
      format.api  do
        @error_messages = [e.message]
        HelpdeskLogger.error  "API Create Ticket Error: #{e.message}" if HelpdeskLogger
        render :template => 'common/error_messages.api', :status => :unprocessable_entity, :layout => nil
      end
    end
  end

  def get_mail
    set_settings

    msg_count = HelpdeskMailer.check_project(@project.id)

    respond_to do |format|
      format.js do
        @message = "<div class='flash notice'> #{l(:label_helpdesk_get_mail_success, :count => msg_count)} </div>"
        flash.discard
      end
      format.html {redirect_to :back}
    end
  rescue Exception => e
     respond_to do |format|
       format.js do
         @message = "<div class='flash error'> Error: #{e.message} </div>"
         Rails.logger.error "Helpdesk MailHandler Error: #{e.message}" if Rails.logger && Rails.logger.error
         flash.discard
       end
       format.html {redirect_to :back}
     end

  end

  def update_customer_email
    @journal = Journal.find(params[:journal_id])
    @issue   = @journal.journalized
    @project = @issue.project
    @display = HelpdeskSettings[:send_note_by_default, @project] ? 'inline' : 'none'
    if @journal.is_incoming?
      @contact = @journal.contact
      @email   = @journal.journal_message.from_address
    else
      @contact = @issue.helpdesk_ticket.last_reply_customer
      @email   = @issue.helpdesk_ticket.default_to_address
    end
  end

  private

  def find_project
    project_id = params[:project_id] || (params[:ticket] && params[:ticket][:issue] && params[:ticket][:issue][:project_id])
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def set_settings
    set_settings_param(:helpdesk_answer_from)
    set_settings_param(:helpdesk_send_notification)
    set_settings_param(:helpdesk_is_not_create_contacts)
    set_settings_param(:helpdesk_created_contact_tag)
    set_settings_param(:helpdesk_blacklist)
    set_settings_param(:helpdesk_emails_header)
    set_settings_param(:helpdesk_answer_subject)
    set_settings_param(:helpdesk_first_answer_subject)
    set_settings_param(:helpdesk_first_answer_template)
    set_settings_param(:helpdesk_emails_footer)
    set_settings_param(:helpdesk_answered_status)
    set_settings_param(:helpdesk_reopen_status)
    set_settings_param(:helpdesk_tracker)
    set_settings_param(:helpdesk_assigned_to)
    set_settings_param(:helpdesk_lifetime)

    set_settings_param(:helpdesk_protocol)
    set_settings_param(:helpdesk_host)
    set_settings_param(:helpdesk_port)
    set_settings_param(:helpdesk_password)
    set_settings_param(:helpdesk_username)

    set_settings_param(:helpdesk_use_ssl)
    set_settings_param(:helpdesk_imap_folder)
    set_settings_param(:helpdesk_move_on_success)
    set_settings_param(:helpdesk_move_on_failure)
    set_settings_param(:helpdesk_apop)
    set_settings_param(:helpdesk_delete_unprocessed)

    set_settings_param(:helpdesk_smtp_use_default_settings)
    set_settings_param(:helpdesk_smtp_server)
    set_settings_param(:helpdesk_smtp_domain)
    set_settings_param(:helpdesk_smtp_port)
    set_settings_param(:helpdesk_smtp_authentication)
    set_settings_param(:helpdesk_smtp_username)
    set_settings_param(:helpdesk_smtp_password)
    set_settings_param(:helpdesk_smtp_tls)
    set_settings_param(:helpdesk_smtp_ssl)

  end

  def set_settings_param(param)
    if param == :helpdesk_password || param == :helpdesk_smtp_password
      ContactsSetting[param, @project.id] = params[param] if params[param] && !params[param].blank?
    else
      ContactsSetting[param, @project.id] = params[param] if params[param]
    end
  end

  def redirect_on_create(options)
    if options[:redirect_on_success].to_s.match('^(http|https):\/\/')
      redirect_to options[:redirect_on_success].to_s
    else
      render :text => "Issue #{@issue.id} created", :status => :created, :location => issue_url(@issue)
    end
  end

end
