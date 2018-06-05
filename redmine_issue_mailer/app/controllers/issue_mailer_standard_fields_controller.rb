class IssueMailerStandardFieldsController < ApplicationController
  unloadable
  include IssueMailSettingsHelper
  helper :issue_mail_settings

  before_filter :find_project_by_project_id
  before_filter :authorize


  def index
    @field = @project.issue_mailer_standard_field
  end

  def new
    @field = @project.build_issue_mailer_standard_field
  end

  def edit
    @field = @project.issue_mailer_standard_field
  end

  def update
    @field = IssueMailerStandardField.update(@project.issue_mailer_standard_field.id, create_update_params)
    respond_to do |format|
      format.html{redirect_to issue_mailer_standard_fields_path(project_id: @project.id), notice: "Success Updated"} unless @field.errors.any?
      format.html{redirect_to edit_issue_mailer_standard_field_path(id: @field.id, project_id: @project.id), flash: {error: @field.errors.full_messages.join(', ')} } if @field.errors.any?
    end
  end

  def create
    @field = @project.create_issue_mailer_standard_field(create_update_params)
    respond_to do |format|
      format.html{redirect_to issue_mailer_standard_fields_path(project_id: @project.id), notice: "Success Created"} unless @field.errors.any?
      format.html{redirect_to new_issue_mailer_standard_field_path(project_id: @project.id), flash: {error: @field.errors.full_messages.join(', ')} } if @field.errors.any?
    end
    
  end

  def destroy
  end

  private
    def create_update_params
      params.require(:issue_mailer_standard_field).permit( :tracker_id, :category_id, :status_id, :assigned_to_id, :priority_id, :fixed_version_id, :start_date, :due_date, :estimated_hours, :done_ratio )
    end
end
