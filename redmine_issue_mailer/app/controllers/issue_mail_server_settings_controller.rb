class IssueMailServerSettingsController < ApplicationController
  unloadable
  include IssueMailSettingsHelper
  helper :issue_mail_settings

  #before_filter :find_project, :authorize
  before_filter :find_project_by_project_id
  before_filter :authorize
  
  before_filter :email_downcase, only: [:create, :update]
  before_filter :find_server_setting, only: [:edit, :update, :destroy ]



  def index
    @server_settings = @project.issue_mail_server_settings
  end

  def show
  end

  def new
    @server_setting = @project.issue_mail_server_settings.new(new_update_params)
  end

  def edit
  end

  def create
    @server_setting = @project.issue_mail_server_settings.create(create_update_params)
    respond_to do |format|
      format.html{redirect_to issue_mail_server_settings_path(project_id: @project.id), notice: "Success Created"} unless @server_setting.errors.any?
      format.html{redirect_to new_issue_mail_server_setting_path(project_id: @project.id, issue_mail_server_setting: params["issue_mail_server_setting"]), flash: {error: @server_setting.errors.full_messages.join(', ')} } if @server_setting.errors.any?
    end

  end

  def update
    @server_setting.update_attributes(create_update_params)
    respond_to do |format|
      format.html{redirect_to issue_mail_server_settings_path(project_id: @project.id), notice: "Success Updated"} unless @server_setting.errors.any?
      format.html{redirect_to edit_issue_mail_server_setting_path(project_id: @project.id, id: params[:id]), flash: {error: @server_setting.errors.full_messages.join(', ')} } if @server_setting.errors.any?
    end
  end

  def destroy
    @server_setting.destroy
    respond_to do |format|
       format.html{redirect_to :back, :flash => { error:  server_setting.errors.full_messages.join(', ') } } if @server_setting.errors.any?
       format.html{redirect_to issue_mail_server_settings_path(project_id: @project.identifier), notice: "Success Deleted"} unless @server_setting.errors.any?
    end
  end

  private
    def email_downcase
      params["issue_mail_server_setting"]["user_name"].replace(params["issue_mail_server_setting"]["user_name"].downcase.gsub(/\s+/, '').lstrip.rstrip)
    end

    def find_server_setting
      @server_setting = @project.issue_mail_server_settings.where("id = ?", params[:id]).first
      if @server_setting.nil?
        render_404
        return
      end
    end

    def new_update_params
      params.permit(:user_name, :password, :password_confirmation, :adress, :domain, :port, :protocol, :authentication, :openssl_verify_mode, :enable_starttls_auto, :ssl, :tls)
    end


    def create_update_params
      params.require(:issue_mail_server_setting).permit(:user_name, :password, :password_confirmation, :adress, :domain, :port, :protocol, :authentication, :openssl_verify_mode, :enable_starttls_auto, :ssl, :tls)
    end
end
