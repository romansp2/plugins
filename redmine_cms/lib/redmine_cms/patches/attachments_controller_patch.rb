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

module RedmineCMS
  module Patches
    module AttachmentsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :find_project, :cms
        end
      end

      module InstanceMethods
        # include ContactsHelper

        def find_project_with_cms
          @attachment = Attachment.find(params[:id])
          # Show 404 if the filename in the url is wrong
          raise ActiveRecord::RecordNotFound if params[:filename] && params[:filename] != @attachment.filename
          @project = @attachment.project if @attachment.respond_to?(:project)
        rescue ActiveRecord::RecordNotFound
          render_404
        end
      end
    end
  end
end

unless AttachmentsController.included_modules.include?(RedmineCMS::Patches::AttachmentsControllerPatch)
  AttachmentsController.send(:include, RedmineCMS::Patches::AttachmentsControllerPatch)
end
