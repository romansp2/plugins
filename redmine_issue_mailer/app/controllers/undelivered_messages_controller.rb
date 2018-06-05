class UndeliveredMessagesController < ApplicationController
  unloadable
  before_filter :permit_all
  before_filter :find_project_by_project_id, except: [:show_from_issue]
  before_filter :find_issue_by_issue_id, only: [:show_from_issue]
  before_filter :authorize


  def index
  	@undelivered_messages = UndeliveredMessage.eager_load(:issue_sent_on_client_email).where("issue_sent_on_client_emails.id = ? AND issue_sent_on_client_emails.project_id = ?", params["sent_email_id"], @project.id)
  end

  def show
  end

  def show_from_issue
  	@undelivered_messages = UndeliveredMessage.eager_load(:issue_sent_on_client_email).where("issue_sent_on_client_emails.id = ? AND issue_sent_on_client_emails.issue_id = ?", params["sent_email_id"], params["issue_id"])
  end

  private
    def permit_all
      params.permit!
    end
end
