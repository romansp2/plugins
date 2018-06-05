class IssueEmailFootersController < ApplicationController
  unloadable
  include IssueMailSettingsHelper
  helper :issue_mail_settings

  before_filter :find_project_by_project_id
  before_filter :authorize

  before_filter :find_footer, only: [:edit, :update, :destroy, :show]




  def index
    @footers = @project.issue_email_footers
  end

  def show
  end

  def new
    @footer = @project.issue_email_footers.new(new_update_params)
  end

  def edit
  end

  def create
    @footer = @project.issue_email_footers.create(create_update_params)
    
    if @footer.errors.any?
      respond_to do |format|
        format.html{redirect_to new_issue_email_footer_path(project_id: @project.id, issue_mail_server_setting: params["issue_email_footer"]), flash: {error: @footer.errors.values.flatten.join(', ')} }
      end
      return
    else
      respond_to do |format|
        format.html{redirect_to issue_email_footers_path(project_id: @project.id), notice: "Success Created"}
      end
      return
    end
    
  end

  def update
    @footer.update_attributes(create_update_params)
    if @footer.errors.any?
      respond_to do |format|
        format.html{redirect_to edit_issue_email_footer_path(project_id: @project.id, issue_mail_server_setting: params["issue_email_footer"]), flash: {error: @footer.errors.values.flatten.join(', ')} }
      end
      return
    else
      respond_to do |format|
        format.html{redirect_to issue_email_footers_path(project_id: @project.id), notice: "Success Updated"}
      end
      return
    end
  end

  def destroy
    if @footer.delete
      respond_to do |format|
        format.html{redirect_to issue_email_footers_path(project_id: @project.id), notice: "Success Deleted"}
      end
      return
    else
      respond_to do |format|
        format.html{redirect_to issue_email_footers_path(project_id: @project.id), flash: {error: @footer.errors.values.flatten.join(', ')} }
      end
      return
    end
  end

  private
    def find_footer
      @footer = @project.issue_email_footers.where("issue_email_footers.id = ?", params["id"]).first
      if @footer.nil?
        render_404
        return
      end
    end

    def new_update_params
      params.permit(:footer)
    end

    def create_update_params
      params.require(:issue_email_footer).permit(:footer)
    end
end
