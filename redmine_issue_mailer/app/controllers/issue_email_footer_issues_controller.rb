class IssueEmailFooterIssuesController < ApplicationController
  unloadable
  include IssueMailSettingsHelper
  helper :issue_mail_settings

  #before_filter :find_project_by_project_id
  before_filter :find_issue_by_issue_id
  before_filter :authorize
  
  before_filter :permit_all
  before_filter :check_params_default_footer, only: [:create, :update]
  before_filter :find_issue_email_footer_create, only: [:create]
  before_filter :find_issue_email_footer_update, only: [:update]

  
  #before_filter :find_footer, only: [:edit, :update, :destroy, :show]


  def index
    @footers = @project.issue_email_footers
    @default_issue_footer = @issue.issue_email_footer_issue
  end

  def show
  end

  def new
  end

  def edit
    @footers = @project.issue_email_footers
    @default_issue_footer = @issue.issue_email_footer_issue || IssueEmailFooterIssue.new
  end

  def create
    @issue_email_footer_issue = @issue_email_footer.issue_email_footer_issues.new(issue_id: @issue.id)
    unless @issue_email_footer_issue.save
      respond_to do |format|
        format.html{redirect_to :back, flash: {error: @issue_email_footer_issue.errors.values.flatten.join(', ')} }
      end
      return
    else
      respond_to do |format|
        format.html{redirect_to :back, notice: "Success Set Default Email Footer"}
      end
      return
    end
  end

  def update
    @issue_email_footer_issue = @issue.issue_email_footer_issue
    @issue_email_footer_issue.update_attributes(issue_email_footer_id: params["issue_email_footer_issue"]["issue_email_footer_id"])
    if @issue_email_footer_issue.errors.any?
      respond_to do |format|
        format.html{redirect_to :back, flash: {error: @issue_email_footer_issue.errors.values.flatten.join(', ')} }
      end
      return
    else
      respond_to do |format|
        format.html{redirect_to :back, notice: "Success Set Default Email Footer"}
      end
      return
    end
  end

  def destroy
  end

  private
    #def find_footer
    #  @footer = @project.issue_email_footers.where("issue_email_footers.id = ?", params["id"]).first
    #  if @footer.nil?
    #    render_404
    #    return
    #  end
    #end
    def check_params_default_footer
      #check params
      #@project.issue_email_footers.where(params["issue_email_footer_issue"]["issue_email_footer_id"]).first
      if params["issue_email_footer_issue"].try(:[], "issue_email_footer_id").blank?
        render_404( message: l(:error_message_you_have_to_choose_footer, scope: [:redmine_issue_mailer]))
        return
      end
    end

    def find_issue_email_footer_create
      @issue_email_footer = @project.issue_email_footers.where(params["issue_email_footer_issue"]["issue_email_footer_id"] ).first
      if @issue_email_footer.nil?
        render_404( message: l(:error_message_can_not_find_footer, scope: [:redmine_issue_mailer]))
        return
      end
    end

    def find_issue_email_footer_update
      @issue_email_footer = @project.issue_email_footers.where(params["issue_email_footer_issue"]["issue_email_footer_id"]).first
      if @issue_email_footer.nil?
        render_404( message: l(:error_message_can_not_find_footer, scope: [:redmine_issue_mailer]))
        return
      end
    end

    def permit_all
      params.permit!
    end
end
