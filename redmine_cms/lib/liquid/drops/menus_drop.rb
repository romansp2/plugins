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

class MenusDrop < Liquid::Drop

  def initialize(menus)
    @menus = menus
  end

  def before_method(name)
    menu = @menus.where(:name => name).first || CmsMenu.new
    MenuDrop.new menu
  end

  def all
    @all ||= @menus.map do |menu|
      MenuDrop.new menu
    end
  end

  def top_menu
    @top_menu ||= @menus.top_menu.map{|m| MenuDrop.new(m)}
  end

  def account_menu
    self.visible.account_menu
  end

  def size
    @menus.count
  end

  def visible
    @visible ||= @menus.visible.map do |menu|
      MenuDrop.new menu
    end
  end

  def each(&block)
    all.each(&block)
  end

end


class MenuDrop < Liquid::Drop

  delegate :name, :caption, :path, :menu_type, :visible?, :active?, :to => :@menu

  def initialize(menu)
    @menu = menu
  end

  def children
    @children ||= @menu.children.map{|p| MenuDrop.new(p)}
  end

  def parent
    @parent ||= MenuDrop.new(@menu.parent) if @menu.parent
  end

  private

  def helpers
    Rails.application.routes.url_helpers
  end

end
