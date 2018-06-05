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

class OperationCategory < ActiveRecord::Base
  unloadable

  attr_accessible :name, :code, :parent_id
  alias :destroy_without_reassign :destroy

  if Redmine::VERSION.to_s < '3.0'
    acts_as_nested_set :dependent => :destroy
  else
    include OperationCategoryNestedSet
  end

  has_many :operations, :foreign_key => "category_id"
  before_destroy :check_integrity

  scope :named, lambda {|arg| where("LOWER(#{table_name}.name) = LOWER(?)", arg.to_s.strip)}

  validates_presence_of :name
  validates_uniqueness_of :name

  def allowed_parents
    @allowed_parents ||= OperationCategory.all - self_and_descendants
  end

  def to_s
    self.self_and_ancestors.map(&:name).join(' &#187; ').html_safe
  end

  def full_name
    self.self_and_ancestors.map(&:name).join(' > ').html_safe
  end

  def css_classes
    puts attributes
    s = 'operation_category'
    s << ' root' if root?
    s << ' child idnt' if child?
    s << (leaf? ? ' leaf' : ' parent')
    s
  end

  def child?
    parent_id.present?
  end

  def root?
    parent_id.nil?
  end

  def self.category_tree(operations, &block)
    ancestors = []
    operations.sort_by(&:lft).each do |category|
      while (ancestors.any? && !category.is_descendant_of?(ancestors.last))
        ancestors.pop
      end
      yield category, category.ancestors.size
      ancestors << category
    end
  end

  def destroy(reassign_to = nil)
    if reassign_to && reassign_to.is_a?(OperationCategory)
      if ActiveRecord::VERSION::MAJOR >= 4
        Operation.where(:category_id => id).update_all(:category_id => reassign_to.id)
      else
        Operation.update_all("category_id = #{reassign_to.id}", "category_id = #{id}")
      end
    end
    destroy_without_reassign
  end

  private


  def check_integrity
    raise "Can't delete category" if Operation.where(:category_id => self.id).any?
  end

end
