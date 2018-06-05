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

Redmine::Plugin.register :redmine_cms do
  name 'Redmine CMS plugin'
  author 'RedmineUP'
  description 'This is a CMS plugin for Redmine'
  version '1.0.0'
  url 'https://redmineup.com/pages/plugins/cms'

  requires_redmine :version_or_higher => '3.0'

  settings :default => {
    "use_localization" => 1,
    "cache_expires" => 10,
    "default_layout" => ''
  }


  permission :view_cms_pages, {:cms_pages => [:show]}, :public => true, :read => true

  project_module :cms do
    permission :view_project_tabs, {
      :project_tabs => [:show]
    }
    permission :manage_project_tabs, {
      :contacts_settings => :save
    }
  end

  Redmine::MenuManager.map :top_menu do |menu|
    #empty
  end

  delete_menu_item(:top_menu, :home)
  delete_menu_item(:top_menu, :"my_page")
  delete_menu_item(:top_menu, :projects)
  delete_menu_item(:top_menu, :help)
  delete_menu_item(:account_menu, :register)

  delete_menu_item(:project_menu, :activity)
  delete_menu_item(:project_menu, :overview)

  10.downto(1) do |index|
    tab = "project_tab_#{index}"
    menu :project_menu, tab, {:controller => 'project_tabs', :action => 'show', :tab => index},
                             :param => :project_id,
                             :first => true,
                             :caption => Proc.new{|p| RedmineCms.get_project_settings("project_tab_#{index}_caption", p.id) || tab.to_s },
                             :if => Proc.new{|p| !RedmineCms.get_project_settings("project_tab_#{index}_caption", p.id).blank? }

  end
  menu :project_menu, :project_tab_last, {:controller => 'project_tabs', :action => 'show', :tab => "last"},
                           :param => :project_id,
                           :last => true,
                           :caption => Proc.new{|p| RedmineCms.get_project_settings("project_tab_last_caption", p.id) || tab.to_s },
                           :if => Proc.new{|p| !RedmineCms.get_project_settings("project_tab_last_caption", p.id).blank? }

  menu :top_menu, :cms, {:controller => 'cms_settings', :action => 'index'}, :first => true, :caption => :label_cms, :parent => :administration

  menu :admin_menu, :cms, {:controller => 'cms_settings', :action => 'index'}, :caption => :label_cms

end

require 'redmine_cms'
require 'redmine/menu'

CmsMenu.rebuild if ActiveRecord::Base.connection.table_exists?(:cms_menus)
