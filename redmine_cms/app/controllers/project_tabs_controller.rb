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

class ProjectTabsController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :authorize
  before_filter :find_page

  helper :cms_pages
  helper :cms

  def show
    unless @page.layout.blank?
      render :text => @page.process(self), :layout => false
    end
  end

private

  def find_page
    tab_name = "project_tab_#{params[:tab]}".to_sym
    menu_items[:project_tabs][:actions][:show] = tab_name
    @page = CmsPage.find_by_name(RedmineCms.get_project_settings("project_tab_#{params[:tab]}_page", @project.id))
    render_404 if @page.blank?
  end

end
