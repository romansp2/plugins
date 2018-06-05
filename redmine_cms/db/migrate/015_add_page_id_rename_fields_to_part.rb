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

class AddPageIdRenameFieldsToPart < ActiveRecord::Migration
  def change
    add_column :cms_parts, :page_id, :integer
    add_column :cms_parts, :description, :string
    add_column :cms_parts, :position, :integer
    add_column :cms_parts, :status_id, :integer, :default => RedmineCms::STATUS_LOCKED

    rename_column :cms_parts, :content_type, :filter_id

    add_index :cms_parts, :page_id
  end
end
