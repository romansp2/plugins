# This file is a part of Redmin CMS (redmine_cms) plugin,
# CMS plugin for redmine
#
# Copyright (C) 2011-2016 RedmineUP
# http://www.redmineup.com/
#
# redmine_cms is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_cms is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_cms.  If not, see <http://www.gnu.org/licenses/>.

class CmsLayoutsController < ApplicationController
  unloadable
  before_filter :authorize_edit
  before_filter :find_layout, :except => [:index, :new, :create]

  helper :attachments
  helper :cms

  def index
    @cms_layouts = CmsLayout.order(:name)
  end

  def new
    @cms_layout = CmsLayout.new
    @cms_layout.copy_from(params[:copy_from]) if params[:copy_from]
  end

  def edit
    @current_version = @cms_layout.set_content_from_version(params[:version]) if params[:version]
  end

  def show
    @current_version = @cms_layout.set_content_from_version(params[:version]) if params[:version]
    @page = CmsPage.new(:content => "Empty content", :layout => @cms_layout)
    render :text => @page.process(self), :layout => false
  end

  def preview
    @current_version = @cms_layout.set_content_from_version(params[:version]) if params[:version]
    @cms_object = @cms_layout
    render :template => 'cms_pages/preview', :layout => 'cms_preview'
  end

  def update
    @cms_layout.assign_attributes(params[:cms_layout])
    @cms_layout.save_attachments(params[:attachments])
    if @cms_layout.save
      render_attachment_warning_if_needed(@cms_layout)
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action =>"edit", :id => @cms_layout
    else
      render :action => 'edit'
    end
  end

  def create
    @cms_layout = CmsLayout.new(params[:cms_layout])
    @cms_layout.save_attachments(params[:attachments])
    if @cms_layout.save
      render_attachment_warning_if_needed(@cms_layout)
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action =>"edit", :id => @cms_layout
    else
      render :action => 'new'
    end
  end

  def destroy
    if params[:version]
      version = @cms_layout.versions.where(:version => params[:version]).first
      if version.current_version?
        flash[:warning] = l(:label_cms_version_cannot_destroy_current)
      else
        version.destroy
      end
      redirect_to cms_object_history_path(@cms_layout, :object_type => @cms_layout.class.name.underscore)
    else
      @cms_layout.destroy
      redirect_to :controller => 'cms_layouts', :action => 'index'
    end
  end

  private

  def find_layout
    @cms_layout = CmsLayout.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def authorize_edit
    deny_access unless RedmineCms.allow_edit?
  end

end
