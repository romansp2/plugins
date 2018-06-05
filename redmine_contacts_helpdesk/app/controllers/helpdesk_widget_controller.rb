class HelpdeskWidgetController < ApplicationController
  unloadable
  layout false
  helper :custom_fields
  protect_from_forgery :except => [:widget, :load_form, :load_custom_fields, :avatar, :create_ticket, :iframe]
  skip_before_filter :check_if_login_required, :only => [:widget, :load_form, :load_custom_fields, :avatar, :create_ticket, :iframe]

  before_filter :prepare_data, :only => [:load_custom_fields, :create_ticket]
  after_filter :set_access_control_header

  def load_form
    render :json => schema.to_json
  end

  def load_custom_fields
    @issue = @project.issues.build(:tracker => @tracker) if @tracker
    @enabled_cf = HelpdeskSettings[:helpdesk_widget_available_custom_fields, nil]
  end

  def avatar
    @user = Project.visible.has_module('contacts_helpdesk').map(&:users).flatten.find { |customer| customer.login == params[:login] }
    return render :nothing => true, :status => 404 unless @user
  end

  def create_ticket
    @issue = prepare_issue
    @issue.helpdesk_ticket = prepare_helpdesk_ticket
    result =
    if valid_email? && @issue.save
      save_attachment(@issue)
      HelpdeskMailer.auto_answer(@issue.helpdesk_ticket.customer, @issue).deliver if HelpdeskSettings[:helpdesk_send_notification, @project].to_i > 0
      { :result => true, :errors => [] }
    else
      { :result => false, :errors => prepared_errors }
    end
    render :json => result
  end

  private

  def prepare_data
    @project = Project.find(params[:project_id])
    @tracker = @project.trackers.where(:id => params[:tracker_id]).first
  end

  def schema
    if HelpdeskSettings[:helpdesk_widget_enable, nil].to_i > 0
      projects = Project.has_module('contacts_helpdesk').where(:id => HelpdeskSettings[:helpdesk_widget_available_projects, nil])
    else
      projects = []
    end
    data_schema = {}
    data_schema[:projects] = Hash[projects.map { |project| [project.name.capitalize, project.id] }]
    data_schema[:projects_data] = {}
    projects.each do |project|
      data_schema[:projects_data][project.id] = {}
      if HelpdeskSettings[:helpdesk_tracker, project] && HelpdeskSettings[:helpdesk_tracker, project] != 'all'
        data_schema[:projects_data][project.id][:trackers] = Hash[Tracker.where(id: HelpdeskSettings[:helpdesk_tracker, project])
                                                                         .map { |tracker| [tracker.name, tracker.id] }]
      else
        data_schema[:projects_data][project.id][:trackers] = Hash[project.trackers.map { |tracker| [tracker.name, tracker.id] }]
      end
    end
    data_schema[:custom_fields] = Hash[IssueCustomField.where(id: HelpdeskSettings[:helpdesk_widget_available_custom_fields, nil])
                                                       .map { |custom_field| [custom_field.name, custom_field.id] }]
    data_schema
  end

  def prepared_errors
    errors_hash = @issue.errors.dup
    # Username
    if errors_hash[:'helpdesk_ticket.customer.first_name'].present?
      @issue.errors.delete(:'helpdesk_ticket.customer.first_name')
      @issue.errors[:username] = errors_hash[:'helpdesk_ticket.customer.first_name'].collect { |error| ['Username', error].join(' ') }
    end

    # Subject
    if errors_hash[:subject].present?
      errors = errors_hash[:subject].collect { |error| ['Subject', error].join(' ') }
      @issue.errors[:subject].clear
      @issue.errors[:subject] = errors
    end

    # Description
    if params[:issue][:description].empty?
      @issue.errors[:description] = I18n.t(:label_helpdesk_widget_ticket_error_description)
    end

    # Nested objects
    if errors_hash[:'helpdesk_ticket.customer.projects'].present?
      @issue.errors.delete(:'helpdesk_ticket.customer.projects')
    end
    @issue.errors
  end

  def prepare_issue
    redmine_user = User.where(id: params[:redmine_user]).first
    author = redmine_user.present? && redmine_user.allowed_to?(:edit_helpdesk_tickets, @project) ? redmine_user : User.anonymous
    issue = @project.issues.build(:tracker => @tracker, :author => author)
    issue.safe_attributes = params[:issue].deep_dup
    issue.assigned_to = widget_contact.find_assigned_user(@project, HelpdeskSettings[:helpdesk_assigned_to, @project])
    issue
  end

  def prepare_helpdesk_ticket
    HelpdeskTicket.new(:from_address => params[:email],
                       :ticket_date  => Time.now,
                       :customer => widget_contact,
                       :issue => @issue,
                       :source => HelpdeskTicket::HELPDESK_WEB_SOURCE)
  end

  def save_attachment(issue)
    return unless params[:attachment].present?
    attachment_hash = split_base64(params[:attachment])
    attachment = Attachment.new(file: Base64.decode64(attachment_hash[:data]))
    attachment.filename = params[:attachment_name] || [Redmine::Utils.random_hex(16), attachment_hash[:extension]].join('.')
    attachment.content_type = attachment_hash[:type]
    attachment.author = User.anonymous
    issue.attachments << attachment
    issue.save
  end

  def split_base64(uri)
    matcher = uri.match(/^data:(.*?)\;(.*?),(.*)$/)
    { type:      matcher[1],
      encoder:   matcher[2],
      data:      matcher[3],
      extension: matcher[1].split('/')[1] }
  end

  def widget_contact
    return @widget_contact if @widget_contact
    contacts = Contact.find_by_emails([params[:email]])
    return @widget_contact = contacts.first if contacts.any?
    @widget_contact = Contact.new(:email => params[:email])
    @widget_contact.first_name, @widget_contact.last_name = params[:username].split(' ')
    @widget_contact.projects << @project
    @widget_contact
  end

  def set_access_control_header
    headers['Access-Control-Allow-Origin'] = '*'
    headers['X-Frame-Options'] = '*'
  end

  def valid_email?
    if params[:email].empty?
      @issue.errors[:email] = 'Email cannot be empty'
      return false
    elsif params[:email].match(/\A([\w\.\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i).nil?
      @issue.errors[:email] = 'Email is incorrect'
      return false
    end
    true
  end
end
