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

class ChecklistTemplateTest < ActiveSupport::TestCase

  def test_save_with_category
    ch_temp_cat = ChecklistTemplateCategory.create(:name => 'Category 1', :position => 1)
    check_list_template = ChecklistTemplate.new(:name => 'name', :category_id => ch_temp_cat.id, :template_items => 's')
    check_list_template.save
    assert_equal ch_temp_cat.id, check_list_template.reload.category.id
  end
end
