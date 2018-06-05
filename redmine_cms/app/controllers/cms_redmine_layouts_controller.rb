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

class CmsRedmineLayoutsController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :find_redmine_layout, :except => [:index, :new, :create]

  helper :cms

  def index
    @cms_redmine_layouts = CmsRedmineLayout.all
  end

  def new
    @cms_redmine_layout = CmsRedmineLayout.new
  end

  def edit
  end

  def update
    new_cms_redmine_layout = CmsRedmineLayout.new(params[:cms_redmine_layout])
    if new_cms_redmine_layout.save
      @cms_redmine_layout.destroy unless new_cms_redmine_layout.redmine_action == @cms_redmine_layout.redmine_action
      flash[:notice] = l(:notice_successful_update)
      redirect_to cms_redmine_layouts_path
    else
      redmine_action = @cms_redmine_layout.redmine_action
      @cms_redmine_layout = new_cms_redmine_layout
      @cms_redmine_layout.redmine_action = redmine_action
      render :action => 'edit'
    end
  end

  def create
    @cms_redmine_layout = CmsRedmineLayout.new(params[:cms_redmine_layout])
    if @cms_redmine_layout.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to cms_redmine_layouts_path
    else
      render :action => 'new'
    end
  end

  def destroy
    @cms_redmine_layout.destroy
    redirect_to cms_redmine_layouts_path
  end

  private

  def find_redmine_layout
    # parametrized_redmine_layouts = CmsRedmineLayout.all.inject({}){|memo, (key, value)| memo[key.parameterize] = {:a => key, :l => value}; memo}
    @cms_redmine_layout = CmsRedmineLayout[params[:id]]
    render_404 unless @cms_redmine_layout
  end
end
