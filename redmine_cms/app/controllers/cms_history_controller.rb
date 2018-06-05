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

class CmsHistoryController < ApplicationController
  unloadable
  before_filter :authorize_edit
  before_filter :find_cms_object

  helper :cms

  def history
    @versions = @cms_object.versions
    @version_count = @versions.count
  end

  def diff
    @diff = @cms_object.diff(params[:version], params[:version_from])
    render_404 unless @diff
  end

  def annotate
    @annotate = @cms_object.annotate(params[:version])
    render_404 unless @annotate
  end

private

  def find_cms_object
    klass = params[:object_type].to_s.singularize.classify.constantize rescue nil
    @cms_object = klass.find_by_id(params[:id])
    if @cms_object.blank? || !@cms_object.respond_to?(:versions)
      render_404
    end
  end

  def authorize_edit
    deny_access unless RedmineCms.allow_edit?
  end

  def set_content_from_version
    return if !@page
    @version = @page.versions.where(:version => params[:version]).first
    if @version
      @current_version = @page.version
      @page.content = @version.content
      @page.version = @version.version
      @page.is_cached = false
    end
  end

end
