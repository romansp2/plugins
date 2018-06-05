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

class CmsPartsController < ApplicationController
  unloadable
  before_filter :require_edit_permission, :except => [:show]
  before_filter :find_part, :except => [:index, :new, :create, :show]
  before_filter :find_page_part, :only => [:show]
  before_filter :authorize_part, :only => [:show]
  before_filter :require_admin, :only => :destroy

  helper :attachments
  helper :cms
  helper :cms_pages

  protect_from_forgery :except => :show

  def index
    redirect_to :controller => 'cms_pages', :action => 'index', :tab => "parts"
  end

  def preview
    @current_version = @part.set_content_from_version(params[:version]) if params[:version]
    @page.listener = self
    @preview_content = @page.render_part(@part)
  end

  def show
    @page.listener = self
    render :text => @page.render_part(@part), :layout => false
  end

  def edit
    @current_version = @part.set_content_from_version(params[:version]) if params[:version]
  end

  def expire_cache
    Rails.cache.delete(@part)
    redirect_to :back
  end

  def new
    @part = CmsPart.new(:filter_id => 'textile', :page_id => params[:page_id])
    @part.copy_from(params[:copy_from]) if params[:copy_from]
  end

  def refresh
    expire_fragment(@part)
  end

  def update
    @part.assign_attributes(params[:part])
    @part.save_attachments(params[:attachments])
    if @part.save
      render_attachment_warning_if_needed(@part)
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html do
          redirect_back_or_default edit_cms_part_path(@part)
        end
        format.js do
          find_parts
          render :action => "change"
        end
      end


    else
      render :action => 'edit'
    end
  end

  def create
    @part = CmsPart.new(params[:part])
    @part.save_attachments(params[:attachments])
    if @part.save
      render_attachment_warning_if_needed(@part)
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action =>"edit", :id => @part
    else
      render :action => 'new'
    end
  end

  def destroy
    if params[:version]
      version = @part.versions.where(:version => params[:version]).first
      if version.current_version?
        flash[:warning] = l(:label_cms_version_cannot_destroy_current)
      else
        version.destroy
      end
      redirect_to history_cms_part_path(@page)
    else
      @part.destroy
      redirect_to :controller => 'cms_pages', :action => 'edit', :tab => "page_parts", :id => @page
    end
  end

private
  def authorize_part
    deny_access unless @part.page.visible?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_parts
    @page = @part.page
    @parts = @page.parts.order(:position)
  end

  def find_page_part
    @part = CmsPart.joins(:page).includes(:page => :attachments).where(:page_id => params[:page_id]).find_part(params[:id] || params[:name])
    raise ActiveRecord::RecordNotFound if @part.blank?
    @page = @part.page
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_part
    @part = CmsPart.includes(:page).find(params[:id])
    @page = @part.page
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def require_edit_permission
    deny_access unless RedmineCms.allow_edit?
  end

end
