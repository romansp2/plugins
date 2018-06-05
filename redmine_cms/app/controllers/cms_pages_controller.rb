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

class CmsPagesController < ApplicationController
  include Redmine::I18n
  include CmsPagesHelper

  unloadable
  before_filter :authorize_page_edit, :except => [:show, :search]
  before_filter :find_page, :only => [:show, :destroy, :preview, :edit, :update, :expire_cache]
  before_filter :authorize_page, :only => [:show]
  before_filter :set_locale, :only => [:show]
  before_filter :require_admin, :only => :destroy

  accept_api_auth :index, :show, :create, :update, :destroy

  helper :attachments
  helper :cms_menus
  helper :cms_parts
  helper :cms

  protect_from_forgery :except => :show

  def index
    scope = CmsPage.order(:name)
    @status = params[:status_id] || RedmineCms::STATUS_ACTIVE
    scope = scope.status(@status)
    scope = scope.where(:visibility => params[:visibility]) if params[:visibility].present?
    scope = scope.where(:layout_id => params[:layout_id]) if params[:layout_id].present?
    scope = scope.tagged_with(params[:tag]) if params[:tag].present?
    scope = scope.like(params[:name]) if params[:name].present?
    @pages = scope
  end

  def show
    if params[:version]
      return false unless authorize_page_edit
      @current_version = @page.set_content_from_version(params[:version])
    end

    # if @page.is_cached?
    #   expires_in RedmineCms.cache_expires_in.minutes, :public => true, :private => false
    # else
    #   expires_in nil, :private => true, "no-cache" => true
    #   headers['ETag'] = ''
    # end
    unless @page.layout.blank?
      render :text => @page.process(self), :layout => false
    end

  end

  def search
    q = (params[:q] || params[:term]).to_s.strip
    if params[:page] && page = CmsPage.find_by_name(params[:page])
      scope = case params[:children]
        when "leaves"
          page.leaves
        when "descendants"
          page.descendants
        else
          page.children
      end
    else
      scope = CmsPage.visible
    end
    scope = scope.includes(:tags)
    scope = scope.limit(params[:limit] || 10)
    q.split(' ').collect{ |search_string| scope = scope.like(search_string) } unless q.blank?
    scope = scope.order(:title)

    if params[:tag]
      tags = params[:tag].split(',')
      tag_options = case params[:match]
        when "any"
          {:match_all => false}
        when "exclude"
          {:exclude => true}
        else
          {:match_all => true}
      end
      scope = scope.tagged_with(tags, tag_options)
    end

    @pages = scope
    render :json => @pages.map{|page| {
      "name" => page.name,
      "slug" => page.slug,
      "path" => page.path,
      "title" => page.title,
      "tags" => page.tag_list}
    }

  end

  def preview
    @current_version = @page.set_content_from_version(params[:version]) if params[:version]
    @cms_object = @page
    render :action => 'preview', :layout => 'cms_preview'
  end

  def edit

    @current_version = @page.set_content_from_version(params[:version]) if params[:version]
    respond_to do |format|
      format.html {render :action => 'edit', :layout => use_layout}
    end
  end

  def new
    @page = CmsPage.new
    @page.page_date = Time.now
    @page.safe_attributes = params[:page]
    @page.layout_id ||= params[:layout_id] || RedmineCms.default_layout
    RedmineCms.default_page_fields.each{|f| @page.fields.build(:name => f)}
    @page.copy_from(params[:copy_from]) if params[:copy_from]
    respond_to do |format|
      format.html {render :action => 'new', :layout => use_layout}
    end
  end

  def update
    @page.assign_attributes(params[:page])
    @page.touch if @page.save_attachments(params[:attachments])
    if @page.save
      render_attachment_warning_if_needed(@page)
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_back_or_default edit_cms_page_path(@page, :tab => params[:tab]) }
        format.js do
          @pages = CmsPage.order(:name)
          render :action => "change"
        end
      end
    else
      render :action => 'edit', :tab => params[:tab]
    end
  end

  def create
    @page = CmsPage.new
    @page.safe_attributes = params[:page]
    @page.author = User.current
    @page.save_attachments(params[:attachments])
    if @page.save
      render_attachment_warning_if_needed(@page)
      flash[:notice] = l(:notice_successful_create)
      redirect_to edit_cms_page_path(@page, :tab => params[:tab])
    else
      render :action => 'new', :tab => params[:tab]
    end
  end

  def destroy
    if params[:version]
      version = @page.versions.where(:version => params[:version]).first
      if version.current_version?
        flash[:warning] = l(:label_cms_version_cannot_destroy_current)
      else
        version.destroy
      end
      redirect_to cms_object_history_path(@page)
    else
      @page.destroy
      redirect_to :controller => 'cms_pages', :action => 'index', :tab => "pages"
    end
  end

  def expire_cache
    @page.expire_cache
    redirect_to :back
  end

private
  def authorize_page
    deny_access unless @page.visible?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_page
    page_scope = CmsPage.includes([:attachments, :parts, :layout])
    @page = params[:id] ? page_scope.find_by_name(params[:id]) : page_scope.find_by_path(params[:path])
    @parts = @page.parts.order(:position) if @page
    render_404 unless @page
  end

  def authorize_page_edit
    unless RedmineCms.allow_edit?
      deny_access
      return false
    end
    true
  end



end
