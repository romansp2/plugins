# encoding: utf-8
#
# This file is a part of Redmine Checklists (redmine_checklists) plugin,
# issue checklists management plugin for Redmine
#
# Copyright (C) 2011-2016 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_checklists is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_checklists is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_checklists.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../test_helper', __FILE__)

class ChecklistTemplateCategoryTest < ActiveSupport::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

  RedmineChecklists::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_checklists).directory + '/test/fixtures/',
                                         [:checklists])
  def setup
    RedmineChecklists::TestCase.prepare
    Setting.default_language = 'en'
    @project_1 = Project.find(1)
    @issue_1 = Issue.create(:project_id => 1, :tracker_id => 1, :author_id => 1,
                            :status_id => 1, :priority => IssuePriority.first,
                            :subject => 'Invoice Issue 1')
    @checklist_1 = Checklist.create(:subject => 'TEST1', :position => 1, :issue => @issue_1)
  end

  test "should exist" do
    assert ChecklistTemplateCategory, "Checklist template category is not defined"
  end

  test "has ordered scope" do
    assert ChecklistTemplateCategory.ordered, "Ordered scope not found for checklist template category model"
  end

  test "should act as list" do
    cat1 = ChecklistTemplateCategory.create!(:name => 'Category 1', :position => 1)
    cat2 = ChecklistTemplateCategory.create!(:name => 'Category 2', :position => 2)
    assert_equal 'Category 2', ChecklistTemplateCategory.ordered.last.name

    cat2.move_higher
    assert_equal ChecklistTemplateCategory.ordered.last.name, 'Category 1'

    cat2.move_to_bottom
    assert_equal ChecklistTemplateCategory.ordered.last.name, 'Category 2'
  end
end
