class IssueSentOnClientEmailsController < ApplicationController
  unloadable
  include IssueMailSettingsHelper
  helper :issue_mail_settings

  before_filter :permit_all
  before_filter :find_project_by_project_id, except: [:show_from_issue]
  before_filter :find_issue_by_issue_id, only: [:show_from_issue]
  before_filter :authorize
  


  def index 
    @filter_form = params["filter"] || {}

    @users_list = User.where("users.id IN (SELECT DISTINCT journals.user_id FROM `journals` INNER JOIN `issue_sent_on_client_emails` ON `issue_sent_on_client_emails`.`journal_id` = `journals`.`id` INNER JOIN `projects` ON `projects`.`id` = `issue_sent_on_client_emails`.`project_id` WHERE (projects.id = ?))", @project.id).to_a

    @list_of_letters = @project.issue_sent_on_client_emails.joins(:journal).eager_load(:undelivered_messages)

    start_date  = Date.parse(@filter_form["start_date"]) if (@filter_form.include?("start_date") and !@filter_form["start_date"].empty?)
    end_date    = Date.parse(@filter_form["end_date"])   if (@filter_form.include?("end_date") and !@filter_form["end_date"].empty?)

    if @filter_form["who_send_id"] && !@filter_form["who_send_id"].empty?
      @list_of_letters = @list_of_letters.where("journals.user_id = ?", @filter_form["who_send_id"])
    end
    if start_date
      @list_of_letters = @list_of_letters.where("issue_sent_on_client_emails.created_at >= ?", start_date.to_s(:db))
    end
    if end_date
      @list_of_letters = @list_of_letters.where("issue_sent_on_client_emails.created_at <= ?", end_date.to_s(:db))
    end
    if @filter_form["to"] && !@filter_form["to"].empty?
      @list_of_letters = @list_of_letters.where("issue_sent_on_client_emails.to LIKE (?)", "%#{@filter_form["to"]}%")
    end
    if @filter_form["bcc"] && !@filter_form["bcc"].empty?
      @list_of_letters = @list_of_letters.where("issue_sent_on_client_emails.bcc LIKE (?)", "%#{@filter_form["bcc"]}%")
    end
    if @filter_form["subject"] && !@filter_form["subject"].empty?
      @list_of_letters = @list_of_letters.where("issue_sent_on_client_emails.subject LIKE (?)", "%#{@filter_form["subject"]}%")
    end
    if @filter_form["issue_id"] && !@filter_form["issue_id"].empty?
      @list_of_letters = @list_of_letters.where("issue_sent_on_client_emails.issue_id = ?", @filter_form["issue_id"])
    end
    if @filter_form["included_attachments"] && !@filter_form["included_attachments"].empty?
      @list_of_letters = @list_of_letters.where("issue_sent_on_client_emails.attachments = ?", @filter_form["included_attachments"])
    end
    if @filter_form["message_id"] && !@filter_form["message_id"].empty?
      @list_of_letters = @list_of_letters.where("issue_sent_on_client_emails.message_id LIKE (?)", "%#{@filter_form["message_id"]}%")
    end
    


    @order_by_start_date = "DESC"
    @order_by_start_date = "ASC" if @filter_form["order_by_start_date"] == "ASC"
    case @order_by_start_date
      when "ASC"
        @list_of_letters = @list_of_letters.order('issue_sent_on_client_emails.created_at ASC')
      when "DESC"
        @list_of_letters = @list_of_letters.order('issue_sent_on_client_emails.created_at DESC')
      else
        @list_of_letters = @list_of_letters.order('issue_sent_on_client_emails.created_at DESC')
    end

    @unique_emails_list =  @list_of_letters.select("DISTINCT issue_sent_on_client_emails.to, issue_sent_on_client_emails.bcc, issue_sent_on_client_emails.cc").
                               map{|email| [email.to, email.bcc, email.cc]}.flatten.uniq.compact.map{|email| email.split(',')}.flatten.uniq
    @unique_emails_list_count = @unique_emails_list.length


    @list_of_letters_count = @list_of_letters.count
    @limit = per_page_option
    @list_of_letter_pages = Paginator.new @list_of_letters_count, @limit, params['page']

    @offset ||= @list_of_letter_pages.offset
    @list_of_letters = @list_of_letters.offset(@offset).limit(@limit)


  end

  def show
  	@letter = @project.issue_sent_on_client_emails.eager_load(:undelivered_messages).where("issue_sent_on_client_emails.id = ? ", params["id"]).first
  	if @letter.nil?
      render_404
      return
    end
  end

  def show_from_issue
    @letter = @issue.issue_sent_on_client_emails.eager_load(:undelivered_messages).where("issue_sent_on_client_emails.id = ? ", params["id"]).first
    if @letter.nil?
      render_404
      return
    end
    render :show_from_issue
  end

  private
    def permit_all
      params.permit!
    end
    
end
