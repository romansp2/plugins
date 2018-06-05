# This file is a part of Redmine Finance (redmine_finance) plugin,
# simple accounting plugin for Redmine
#
# Copyright (C) 2011-2016 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_finance is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_finance is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_finance.  If not, see <http://www.gnu.org/licenses/>.

class AddParentIdToOperationCategories < ActiveRecord::Migration
  def change
    add_column :operation_categories, :parent_id, :integer
    add_column :operation_categories, :lft, :integer
    add_column :operation_categories, :rgt, :integer
    add_column :operation_categories, :code, :string

    add_index :operation_categories, [:lft]
    add_index :operation_categories, [:rgt]

  end
end
