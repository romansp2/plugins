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


class ProjectsDrop < Liquid::Drop

  def initialize(projects)
    @projects = projects
  end

  def before_method(identifier)
    project = @projects.where(:identifier => identifier).first || Project.new
    ProjectDrop.new project
  end

  def all
    @all ||= @projects.map do |project|
      ProjectDrop.new project
    end
  end

  def active
    @active ||= @projects.select(&:active?).map do |project|
      ProjectDrop.new project
    end
  end

  def each(&block)
    all.each(&block)
  end

  def size
    @projects.size
  end

end


class ProjectDrop < Liquid::Drop
  include ActionView::Helpers::UrlHelper

  delegate :id,
           :identifier,
           :name,
           :is_public,
           :description,
           :visible?,
           :active?,
           :archived?,
           :short_description,
           :start_date,
           :due_date,
           :overdue?,
           :completed_percent,
           :created_on,
           :updated_on,
           :to => :@project

  def initialize(project)
    @project = project
  end

  def link
    link_to @project.name, self.url
  end

  def url
    Rails.application.routes.url_helpers.project_path(@project)
  end

  def issues
    @issues ||= IssuesDrop.new @project.issues.visible
  end

  def users
    @users ||= UsersDrop.new @project.users
  end

  def subprojects
    @subprojects ||= ProjectsDrop.new @project.children
  end

end

