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

class CmsSettingsController < ApplicationController
  unloadable
  menu_item :cms_settings

  before_filter :require_admin
  before_filter :find_settings

  helper :cms

  def index
  end

  def redmine_hooks

  end

  def update
    params[:settings].each do |key, value|
      @settings[key] = value
    end
    Setting.plugin_redmine_cms = @settings
    flash[:notice] = l(:notice_successful_update)
    redirect_back_or_default :action => 'index', :tab => params[:tab]
  end

  def edit
  end

  def save
    find_project_by_project_id
    if params[:cms_settings] && params[:cms_settings].is_a?(Hash) then
      settings = params[:cms_settings]
      settings.map do |k, v|
        # ContactsSetting[k, @project.id] = v
        RedmineCms.set_project_settings(k, @project.id, v)
      end
    end
    redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => params[:tab]
  end


private

  def find_settings
    @settings = Setting.plugin_redmine_cms
    @settings = {} unless @settings.is_a?(Hash)
  end

end
