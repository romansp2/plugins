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

module RedmineCms
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :show, :cms

          helper :cms_pages
          helper :cms
        end
      end

      module InstanceMethods

        def show_with_cms
          if params[:jump]
            # try to redirect to the requested menu item
            redirect_to_project_menu_item(@project, params[:jump]) && return
          end

          unless !User.current.allowed_to?(:view_project_tabs, @project) || (page_path = RedmineCms.get_project_settings("landing_page", @project.id)).blank?
            if page_path.to_i > 0 && page_path.to_i < 11
              page_path = {:controller => 'project_tabs', :action => 'show', :tab => page_path.to_i.to_s, :project_id => @project}
            end
            redirect_to page_path, :status => 301
          else
            show_without_cms
          end
        end

      end

    end
  end
end


unless ProjectsController.included_modules.include?(RedmineCms::Patches::ProjectsControllerPatch)
  ProjectsController.send(:include, RedmineCms::Patches::ProjectsControllerPatch)
end
