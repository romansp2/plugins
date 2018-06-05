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

require_dependency 'queries_helper'

module RedmineCms
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method_chain :project_settings_tabs, :project_tab          
        end
      end


      module InstanceMethods
        # include ContactsHelper

        def project_settings_tabs_with_project_tab
          tabs = project_settings_tabs_without_project_tab
          tabs.push({ :name => 'project_tab',
            :action => :manage_project_tabs,
            :partial => 'projects/settings/project_tab_settings',
            :label => :label_project_tab })

          tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
        end
        
      end
      
    end
  end
end

unless ProjectsHelper.included_modules.include?(RedmineCms::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedmineCms::Patches::ProjectsHelperPatch)
end
