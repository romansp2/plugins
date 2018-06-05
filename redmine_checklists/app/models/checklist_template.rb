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

class ChecklistTemplate < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :user
  belongs_to :category, :class_name => "ChecklistTemplateCategory", :foreign_key => "category_id"

  validates_presence_of :name, :template_items
  validates_length_of :name, :maximum => 255

  attr_accessible :name, :template_items, :project, :user, :category_id, :is_public

  scope :visible, lambda {|*args|
    user = args.shift || User.current
    base = Project.allowed_to_condition(user, :manage_checklist_templates, *args)
    user_id = user.logged? ? user.id : 0

    eager_load(:project).where("(#{table_name}.project_id IS NULL OR (#{base})) AND (#{table_name}.is_public = ? OR #{table_name}.user_id = ?)", true, user_id)
  }

  scope :in_project_and_global, lambda {|project|
    where("#{table_name}.project_id IS NULL OR #{table_name}.project_id = 0 OR #{table_name}.project_id = ?", project)
  }

  def to_s
    name
  end

end
