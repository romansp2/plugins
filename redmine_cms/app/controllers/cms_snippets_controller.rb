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

class CmsSnippetsController < ApplicationController
  unloadable
  before_filter :require_edit_permission
  before_filter :find_snippet, :except => [:index, :new, :create]

  helper :attachments
  helper :cms
  helper :cms_pages

  def index
    @snippets = CmsSnippet.order(:name)
  end

  def preview
    @current_version = @cms_snippet.set_content_from_version(params[:version]) if params[:version]
    page = CmsPage.new(:listener => self)
    @preview_content = page.render_part(@cms_snippet)
  end

  def edit
    @current_version = @cms_snippet.set_content_from_version(params[:version]) if params[:version]
  end

  def new
    @cms_snippet = CmsSnippet.new(:filter_id => 'textile')
    @cms_snippet.copy_from(params[:copy_from]) if params[:copy_from]
  end

  def update
    @cms_snippet.assign_attributes(params[:cms_snippet])
    @cms_snippet.save_attachments(params[:attachments])
    if @cms_snippet.save
      render_attachment_warning_if_needed(@cms_snippet)
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_back_or_default edit_cms_snippet_path(@cms_snippet) }
      end
    else
      render :action => 'edit'
    end
  end

  def create
    @cms_snippet = CmsSnippet.new(params[:cms_snippet])
    @cms_snippet.save_attachments(params[:attachments])
    if @cms_snippet.save
      render_attachment_warning_if_needed(@cms_snippet)
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action =>"edit", :id => @cms_snippet
    else
      render :action => 'new'
    end
  end

  def destroy
    if params[:version]
      version = @cms_snippet.versions.where(:version => params[:version]).first
      if version.current_version?
        flash[:warning] = l(:label_cms_version_cannot_destroy_current)
      else
        version.destroy
      end
      redirect_to history_cms_snippet_path(@page)
    else
      @cms_snippet.destroy
      redirect_to :controller => 'cms_snippets', :action => 'index'
    end
  end


private
  def find_snippets
    @snippets = CmsSnippet.order(:name)
  end

  def find_snippet
    @cms_snippet = CmsSnippet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def require_edit_permission
    deny_access unless RedmineCms.allow_edit?
  end


end
