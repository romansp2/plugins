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

class CmsRedirectsController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :find_redirect, :except => [:index, :new, :create]

  helper :cms

  def index
    @cms_redirects = CmsRedirect.all
  end

  def new
    @cms_redirect = CmsRedirect.new
  end

  def edit
  end

  def update
    new_cms_redirect = CmsRedirect.new(params[:cms_redirect])
    if new_cms_redirect.save
      @cms_redirect.destroy unless new_cms_redirect.source_path == @cms_redirect.source_path
      flash[:notice] = l(:notice_successful_update)
      redirect_to cms_redirects_path
    else
      source_path = @cms_redirect.source_path
      @cms_redirect = new_cms_redirect
      @cms_redirect.source_path = source_path
      render :action => 'edit'
    end
  end

  def create
    @cms_redirect = CmsRedirect.new(params[:cms_redirect])
    if @cms_redirect.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to cms_redirects_path
    else
      render :action => 'new'
    end
  end

  def destroy
    @cms_redirect.destroy
    redirect_to cms_redirects_path
  end

  private

  def find_redirect
    parametrized_redirects = RedmineCms.redirects.map{|k, v| [k, v]}.inject({}){|memo, (key, value)| memo[key.parameterize] = {:s => key, :d => value}; memo}
    redirect = parametrized_redirects[params[:id].gsub(/^_$/, "")]
    render_404 unless redirect
    @cms_redirect = CmsRedirect.new(:source_path => redirect.try(:[], :s), :destination_path => redirect.try(:[], :d))
  end
end
