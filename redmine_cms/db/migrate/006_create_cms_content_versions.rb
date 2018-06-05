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

class CreateCmsContentVersions < ActiveRecord::Migration
  def change
    create_table :cms_content_versions do |t|
      t.column :version, :integer, :null => false
      t.column :comments, :string
      t.column :content, :text
      t.column :author_id, :integer
      t.column :versionable_type, :string, :default => "", :null => false
      t.column :versionable_id, :integer, :default => 0, :null => false
    end
    add_index :cms_content_versions, :versionable_id
    add_index :cms_content_versions, [:versionable_id, :versionable_type], :name => "index_cms_content_versions_on_versionable", :using => :btree
  end
end
