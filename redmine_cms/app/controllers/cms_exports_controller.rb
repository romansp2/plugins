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

class CmsExportsController < ApplicationController
  unloadable
  before_filter :authorize_edit
  before_filter :find_cms_object, except: [:website]
  before_filter :build_export_object, :only => [:new, :create]

  def create
    @cms_export.configure(params[:cms_export])
    send_data(@cms_export.export, :type => 'text/yaml; header=present', :filename => [@cms_object.name, 'yaml'].join('.'))
  end

  def website
    if request.post?
      @cms_export = CmsExport.new(params[:object_type])
      @cms_export.configure(params)
      send_data(@cms_export.export_website, :type => 'text/yaml; header=present', :filename => ['website', 'yaml'].join('.'))
    end
  end

  private

  def find_cms_object
    raise ActiveRecord::RecordNotFound unless params[:object_type]
    klass = params[:object_type].to_s.singularize.classify.constantize
    @cms_object = klass.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def build_export_object
    @cms_export = CmsExport.new(@cms_object)
  end

  def authorize_edit
    deny_access unless RedmineCms.allow_edit?
  end
end
