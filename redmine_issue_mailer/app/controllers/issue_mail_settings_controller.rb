class IssueMailSettingsController < ApplicationController
  unloadable
  include IssueMailSettingsHelper
  helper :issue_mail_settings
  #before_filter :find_project, :authorize
  before_filter :find_project_by_project_id, :authorize


  def index
    
  end

  #def show
  #end

  #def new
  #end

  #def edit
  #end

  #def create
  #end

  #def update
  #end

  #def destroy
  #end
end
