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

class CmsImportsController < ApplicationController
  unloadable
  before_filter :authorize_edit
  before_filter :build_import_object, :only => [:new, :create]

  def create
    @cms_import.configure(params[:cms_import])
    @cms_object = @cms_import.import
  end

  def website
    if request.post?
      @cms_import = CmsImport.new(params[:object_type])
      @cms_import.author = User.current
      @cms_import.configure(params)
      @cms_import.import_website
      return redirect_to cms_settings_path
    end
  end

  private

  def build_import_object
    @cms_import = CmsImport.new(params[:object_type].to_s.singularize.classify.constantize.new)
    @cms_import.author = User.current
  end

  def authorize_edit
    deny_access unless RedmineCms.allow_edit?
  end
end
