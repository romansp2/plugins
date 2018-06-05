# This file is a part of Redmine Checklists (redmine_checklists) plugin,
# issue checklists management plugin for Redmine
#
# Copyright (C) 2011-2016 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_checklists is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_checklists is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_checklists.  If not, see <http://www.gnu.org/licenses/>.


module RedmineChecklists
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method_chain :project_settings_tabs, :checklists
        end
      end

      module InstanceMethods
        def project_settings_tabs_with_checklists
          tabs = project_settings_tabs_without_checklists
          tab = { :name => 'checklist_template',
                  :action => :manage_checklist_templates,
                  :partial => 'projects/settings/checklist_templates',
                  :label => :label_checklist_templates }
          tabs << tab if User.current.allowed_to?(:edit_issues, @project) && User.current.allowed_to?(tab[:action], @project)
          tabs
        end
      end
    end
  end
end

unless ProjectsHelper.included_modules.include?(RedmineChecklists::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedmineChecklists::Patches::ProjectsHelperPatch)
end
