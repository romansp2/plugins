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

class CmsMenusController < ApplicationController
  unloadable

  before_filter :require_edit_permission
  before_filter :find_menu, :except => [:index, :new, :create, :parent_menu_options]

  helper :cms

  def index
    @cms_menus = CmsMenu.all
  end

  def edit

  end

  def new
    @cms_menu = CmsMenu.new(:menu_type => 'top_menu')
  end

  def update
    @cms_menu.assign_attributes(params[:menu])
    if @cms_menu.save
      flash[:notice] = l(:notice_successful_update)
      @cms_menus = CmsMenu.all
      respond_to do |format|
        format.html {render :action =>"edit", :id => @cms_menus}
        format.js {render :action => "change"}
      end
    else
      render :action => 'edit'
    end
  end

  def create
    @cms_menu = CmsMenu.new(params[:menu])
    if @cms_menu.save
      flash[:notice] = l(:notice_successful_create)
      render :action => 'edit', :id => @cms_menu
    else
      render :action => 'new'
    end
  end

  def destroy
    @cms_menu.destroy
    redirect_to :controller => 'cms_pages', :action => 'index', :tab => "cms_menus"
  end

  def parent_menu_options
    unless params[:id].blank?
      find_menu
    else
      @cms_menu = CmsMenu.new(:menu_type => params[:menu_type])
    end
  end

private
  def find_menu
    @cms_menu = CmsMenu.find(params[:id])
  end


  def require_edit_permission
    deny_access unless RedmineCms.allow_edit?
  end

end
