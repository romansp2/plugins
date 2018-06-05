# encoding: utf-8
#
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

module CmsMenusHelper

  def change_menu_status_link(cms_menu)
    url = {:controller => 'cms_menus', :action => 'update', :id => cms_menu, :cms_menu => params[:cms_menu], :status => params[:status], :tab => nil}

    if cms_menu.active?
      link_to l(:button_lock), url.merge(:cms_menu => {:status_id => RedmineCms::STATUS_LOCKED}), :method => :put, :class => 'icon icon-lock'
    else
      link_to l(:button_unlock), url.merge(:cms_menu => {:status_id => RedmineCms::STATUS_ACTIVE}), :method => :put, :class => 'icon icon-unlock'
    end
  end

  def menus_options_for_select(menus)
    options = []
    CmsMenu.menu_tree(menus) do |menu, level|
      label = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
      label << menu.caption
      options << [label, menu.id]
    end
    options
  end

  def cms_menus_tree(menus, &block)
    CmsMenu.menu_tree(menus, &block)
  end

end
