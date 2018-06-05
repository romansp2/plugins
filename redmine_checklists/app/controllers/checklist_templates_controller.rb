# This file is a part of Redmine Checklists (redmine_checklists) plugin,
# issue checklists management plugin for Redmine
#
# Copyright (C) 2011-2016 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_checklists is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_checklists is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_checklists.  If not, see <http://www.gnu.org/licenses/>.

class ChecklistTemplatesController < ApplicationController
  unloadable

  before_filter :find_checklist_template, :except => [:new, :create, :index]
  before_filter :find_optional_project, :only => [:new, :create, :add, :destroy, :edit, :update]
  before_filter :require_admin, :only => [:index]

  def new
    @checklist_template = ChecklistTemplate.new
    @checklist_template.user = User.current
    @checklist_template.project = @project
    @checklist_template.is_public = false unless User.current.allowed_to?(:manage_checklist_templates, @project) || User.current.admin?
  end

  def create
    @checklist_template = ChecklistTemplate.new(params[:checklist_template])
    @checklist_template.user = User.current
    @checklist_template.project = params[:checklist_template_is_for_all] && User.current.admin? ? nil : @project
    @checklist_template.is_public = false unless User.current.allowed_to?(:manage_checklist_templates, @project) || User.current.admin?

    if @checklist_template.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to_project_or_global
    else
      render :action => 'new', :layout => !request.xhr?
    end
  end

  def edit
  end

  def update
    @checklist_template.attributes = params[:checklist_template]
    @checklist_template.project = nil if params[:checklist_template_is_for_all]
    @checklist_template.project = @project if params[:checklist_template][:is_public] == '1' && !User.current.admin?
    @checklist_template.project = (params[:checklist_template_is_for_all] && User.current.admin?) ? nil : @project
    @checklist_template.is_public = false unless User.current.allowed_to?(:manage_checklist_templates, @project) || User.current.admin?

    if @checklist_template.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to_project_or_global
    else
      render :action => 'edit'
    end
  end

  def destroy
    @checklist_template.destroy
    redirect_to_project_or_global
  end

private
  def redirect_to_project_or_global
    redirect_to @project ? settings_project_path(@project, :tab => 'checklist_template') : {:action => "plugin", :id => "redmine_checklists", :controller => "settings", :tab => 'checklist_templates'}
  end

  def find_issue
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_checklist_template
    @checklist_template = ChecklistTemplate.where('id = ? AND (user_id = ? OR is_public = true)', params[:id].to_i, User.current.id).first
    raise ActiveRecord::RecordNotFound unless @checklist_template.present?
    @project = @checklist_template.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
