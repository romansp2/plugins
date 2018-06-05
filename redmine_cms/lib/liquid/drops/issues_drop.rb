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

class IssuesDrop < Liquid::Drop

  def initialize(issues)
    @issues = issues
  end

  def before_method(id)
    issue = @issues.where(:id => id).first || Issue.new
    IssueDrop.new issue
  end

  def all
    @all ||= @issues.map do |issue|
      IssueDrop.new issue
    end
  end

  def each(&block)
    all.each(&block)
  end

  def size
    @issues.size
  end

end


class IssueDrop < Liquid::Drop
  include ActionView::Helpers::UrlHelper

  delegate :id,
           :subject,
           :description,
           :visible?,
           :open?,
           :start_date,
           :due_date,
           :overdue?,
           :completed_percent,
           :updated_on,
           :created_on,
           :to => :@issue

  def initialize(issue)
    @issue = issue
  end

  def link
    link_to @issue.name, self.url
  end

  def url
    Rails.application.routes.url_helpers.issue_path(@issue)
  end

  def author
    @users ||= UsersDrop.new @issue.author
  end

end

