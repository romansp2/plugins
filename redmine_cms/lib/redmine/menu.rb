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

Redmine::MenuManager.map :top_menu do |menu|
    menu.push :adm_projects, {:controller => 'admin', :action => 'projects'}, :caption => :label_project_plural, :parent => :administration
    menu.push :adm_users, {:controller => 'users'}, :caption => :label_user_plural, :parent => :administration
    menu.push :adm_groups, {:controller => 'groups'}, :caption => :label_group_plural, :parent => :administration
    menu.push :adm_roles, {:controller => 'roles'}, :caption => :label_role_and_permissions, :parent => :administration
    menu.push :adm_trackers, {:controller => 'trackers'}, :caption => :label_tracker_plural, :parent => :administration
    menu.push :adm_issue_statuses, {:controller => 'issue_statuses'}, :caption => :label_issue_status_plural, :html => {:class => 'issue_statuses'}, :parent => :administration
    menu.push :adm_workflows, {:controller => 'workflows', :action => 'edit'}, :caption => :label_workflow, :parent => :administration
    menu.push :adm_custom_fields, {:controller => 'custom_fields'},  :caption => :label_custom_field_plural, :html => {:class => 'custom_fields'}, :parent => :administration
    menu.push :adm_enumerations, {:controller => 'enumerations'}, :caption => :label_enumerations, :parent => :administration
    menu.push :adm_settings, {:controller => 'settings'}, :caption => :label_settings, :parent => :administration
    menu.push :adm_ldap_authentication, {:controller => 'auth_sources', :action => 'index'}, :caption => :label_ldap_authentication, :html => {:class => 'server_authentication'}, :parent => :administration
    menu.push :adm_plugins, {:controller => 'admin', :action => 'plugins'}, :caption => :label_plugins, :last => true, :parent => :administration
    menu.push :adm_info, {:controller => 'admin', :action => 'info'}, :caption => :label_information_plural, :last => true, :parent => :administration

    menu.push :projects, { :controller => 'projects', :action => 'index' }, :caption => :label_project_plural, :if => Proc.new { Setting.plugin_redmine_cms["show_projects"].to_i > 0 }, :first => true
    menu.push :home, { :controller => 'welcome', :action => 'index' }, :if => Proc.new { Setting.plugin_redmine_cms["show_home"].to_i > 0 }, :first => true
    menu.push :help, Redmine::Info.help_url, :last => true, :if => Proc.new { Setting.plugin_redmine_cms["show_help"].to_i > 0 }
end

Redmine::MenuManager.map :account_menu do |menu|
    menu.push :my_page, { :controller => 'my', :action => 'page' }, :if => Proc.new { User.current.logged? }, :after => :my_account
end

Redmine::MenuManager.map :project_menu do |menu|
  menu.push :activity, { :controller => 'activities', :action => 'index' }, :if => Proc.new{|p| !p.module_enabled?(:cms) || RedmineCms.get_project_settings("project_tab_show_activity", p.id).to_i > 0 }, :after => :new_object
  menu.push :overview, { :controller => 'projects', :action => 'show' }, :if => Proc.new{|p| !p.module_enabled?(:cms) || RedmineCms.get_project_settings("landing_page", p.id).blank? }, :after => :new_object
end
