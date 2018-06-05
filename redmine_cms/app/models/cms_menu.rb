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

class CmsMenu < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  belongs_to :source, :polymorphic => true

  acts_as_list :scope => 'menu_type = \'#{menu_type}\' AND parent_id #{parent_id ? \'=\' + parent_id.to_s : \'IS NULL\'}'
  acts_as_tree :dependent => :nullify

  default_scope {order(:menu_type).order(:position)}
  scope :active, lambda {where(:status_id => RedmineCms::STATUS_ACTIVE)}
  scope :visible, lambda { where(CmsMenu.visible_condition) }
  scope :top_menu, lambda{where(:menu_type => "top_menu")}
  scope :account_menu, lambda{where(:menu_type => "account_menu")}

  after_commit :rebuild_menu
  after_destroy :rebuild_menu

  validates_presence_of :name, :caption
  validates_uniqueness_of :name, :scope => :menu_type
  validates_length_of :name, :maximum => 30
  validates_length_of :caption, :maximum => 255
  validate :validate_menu
  validate :uniqueness_in_menu_manager, :on => :create
  validates_format_of :name, :with => /\A(?!\d+$)[a-z0-9\-_]*\z/

  @cached_cleared_on = Time.now

  attr_protected :id
  safe_attributes 'name',
    'caption',
    'path',
    'position',
    'status_id',
    'visibility',
    'menu_type'

  def self.visible_condition(user=User.current)
    user_ids = [user.id] + user.groups.map(&:id)
    return "(1=1)" if user.admin?
    cond = ""
    cond << " ((#{table_name}.visibility = 'public')"
    cond << " OR (#{table_name}.visibility = 'logged')" if user.logged?
    cond << " OR (#{table_name}.visibility IN (#{user_ids.join(',')})))" if user.logged?
  end

  def visible?(user=User.current)
    return true if user.admin?
    return true if visibility == 'public'
    return true if visibility == 'logged' && user.logged?
    user_ids = [user.id] + user.groups.map(&:id)
    return true if user_ids.include?(visibility.to_i) && user.logged?
    false
  end

  def active?
    self.status_id == RedmineCms::STATUS_ACTIVE
  end

  def rebuild_menu
    # CmsMenu.rebuild
    CmsMenu.clear_cache
  end

  def reload(*args)
    @valid_parents = nil
    super
  end

  def self.menu_tree(menus, parent_id=nil, level=0)
    tree = []
    menus.select {|menu| menu.parent_id == parent_id}.sort_by(&:position).sort_by(&:menu_type).each do |menu|
      tree << [menu, level]
      tree += menu_tree(menus, menu.id, level+1)
    end
    if block_given?
      tree.each do |menu, level|
        yield menu, level
      end
    end
    tree
  end

  def self.check_cache
    menu_updated_on = CmsMenu.maximum(:updated_at)
    if menu_updated_on && @cached_cleared_on <= menu_updated_on
      clear_cache
    end
  end

  # Clears the settings cache
  def self.clear_cache
    CmsMenu.rebuild
    @cached_cleared_on = Time.now
    logger.info "Menu cache cleared." if logger
  end

  def self.rebuild
    Redmine::MenuManager.map :top_menu do |menu|
      CmsMenu.top_menu.each{|m| menu.delete(m.name.to_sym) }

      CmsMenu.active.top_menu.where(:parent_id => nil).each do |cms_menu|
        menu.push(
          cms_menu.name,
          cms_menu.path,
          :caption => cms_menu.caption,
          :first => cms_menu.first?,
          :if => Proc.new{|p| cms_menu.visible? }
        ) unless menu.exists?(cms_menu.name.to_sym)
      end

      CmsMenu.active.top_menu.where("#{CmsMenu.table_name}.parent_id IS NOT NULL").each do |cms_menu|
        menu.push(
          cms_menu.name.to_sym,
          cms_menu.path,
          :parent => cms_menu.parent.name.to_sym,
          :caption => cms_menu.caption, :if => Proc.new{|p| cms_menu.visible? && cms_menu.parent.visible?  }
        ) if cms_menu.parent.active? && !menu.exists?(cms_menu.name.to_sym)

      end
    end

    Redmine::MenuManager.map :account_menu do |menu|
      CmsMenu.account_menu.each{|m| menu.delete(m.name.to_sym) }

      CmsMenu.active.account_menu.where(:parent_id => nil).each do |cms_menu|
        menu.push(
          cms_menu.name,
          cms_menu.path,
          :caption => cms_menu.caption,
          :first => cms_menu.first?
        ) unless menu.exists?(cms_menu.name.to_sym)
      end

      CmsMenu.active.account_menu.where("#{CmsMenu.table_name}.parent_id IS NOT NULL").each do |cms_menu|
        menu.push(
          cms_menu.name.to_sym,
          cms_menu.path,
          :parent => cms_menu.parent.name.to_sym,
          :caption => cms_menu.caption) if cms_menu.parent.active? && cms_menu.parent.visible? && !menu.exists?(cms_menu.name.to_sym)

      end
    end

  end

  def valid_parents
    @valid_parents ||= (self.children.any? ? [] : CmsMenu.where(:menu_type => self.menu_type, :parent_id => nil) - self_and_descendants)
  end

  protected

  def validate_menu
    if parent_id && parent_id_changed?
      errors.add(:parent_id, :invalid) unless valid_parents.include?(parent)
    end
  end

  def uniqueness_in_menu_manager
    if Redmine::MenuManager.items(menu_type.to_sym).detect { |i| i.name.to_s == name }
      errors.add(:name, :taken)
    end
  end
end
