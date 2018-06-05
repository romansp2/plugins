class IssueMailerCustomFieldsController < ApplicationController
  unloadable
  include IssueMailSettingsHelper
  helper :issue_mail_settings
  include CustomFieldsHelper
  helper :custom_fields

  include IssueMailerCustomFieldsHelper
  helper :issue_mailer_custom_fields

  before_filter :permit_all
  before_filter :find_project_by_project_id, :authorize


  def index
    issue = @project.issues.new
    issue.tracker = @project.trackers.first
    issue.status = issue.new_statuses_allowed_to(User.current, include_default=true).first
    
    @custom_field_values = issue.editable_custom_field_values

    @project_mailer_custom_field_value = @project.issue_mailer_custom_field_value || @project.build_issue_mailer_custom_field_value(value: {})
    
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
    @project_mailer_custom_field_value = @project.issue_mailer_custom_field_value || @project.build_issue_mailer_custom_field_value
    @project_mailer_custom_field_value.value = params.try(:[], "issue").try(:[], "custom_field_values") || {}
    @project_mailer_custom_field_value.save
    
    respond_to do |format|
      format.html{redirect_to issue_mailer_custom_fields_path(project_id: @project.identifier), notice: "Success Updated"} unless @project_mailer_custom_field_value.errors.any?
      format.html{redirect_to issue_mailer_custom_fields_path(project_id: @project.identifier), flash: {error: @project_mailer_custom_field_value.errors.full_messages.join(', ')} } if @project_mailer_custom_field_value.errors.any?
    end
    #"issue"=>{"custom_field_values"=>{"6"=>"1", "7"=>"1", "10"=>"2", "12"=>"kljlkjlkjlkjlkjlkjlkjlk", "13"=>["198", "199", "203", "209", ""], "15"=>"", "16"=>"", "17"=>""}}, "button"=>""}

  end

  def destroy
  end

  def permit_all
    params.permit!
  end
  
end
