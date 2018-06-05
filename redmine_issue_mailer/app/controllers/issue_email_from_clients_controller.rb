class IssueEmailFromClientsController < ApplicationController
  unloadable
  include IssueMailSettingsHelper
  helper :issue_mail_settings

  before_filter :permit_all
  before_filter :find_project_by_project_id, except: [:show_from_issue]
  before_filter :find_issue_by_issue_id, only: [:show_from_issue]
  before_filter :authorize

  def index
  	@list_of_emails = @project.issue_email_from_clients

    @list_of_emails_count = @list_of_emails.count
    @limit = per_page_option
    @list_of_emails_pages = Paginator.new @list_of_emails_count, @limit, params['page']

    @offset ||= @list_of_emails_pages.offset
    @emails = @list_of_emails.offset(@offset).limit(@limit)
  end

  def show
  	@email = @project.issue_email_from_clients.where("id = ?", params[:id])
  end

  def show_from_issue
    @email = @issue.issue_email_from_clients.where("id = ?", params[:id])
  end

  
  def permit_all
    params.permit!
  end
end
