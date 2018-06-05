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

class CmsVariablesController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :find_variable, :except => [:index, :new, :create]

  helper :cms

  def index
    @cms_variables = CmsVariable.all
  end

  def new
    @cms_variable = CmsVariable.new
  end

  def edit
  end

  def update
    new_cms_variable = CmsVariable.new(params[:cms_variable])
    if new_cms_variable.save
      @cms_variable.destroy unless new_cms_variable.name == @cms_variable.name
      flash[:notice] = l(:notice_successful_update)
      redirect_to cms_variables_path
    else
      name = @cms_variable.name
      @cms_variable = new_cms_variable
      @cms_variable.name = name
      render :action => 'edit'
    end
  end

  def create
    @cms_variable = CmsVariable.new(params[:cms_variable])
    if @cms_variable.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to cms_variables_path
    else
      render :action => 'new'
    end
  end

  def destroy
    @cms_variable.destroy
    redirect_to cms_variables_path
  end

  private

  def find_variable
    # parametrized_variables = CmsVariable.all.inject({}){|memo, (key, value)| memo[key.parameterize] = {:a => key, :l => value}; memo}
    @cms_variable = CmsVariable[params[:id]]
    render_404 unless @cms_variable
  end
end
