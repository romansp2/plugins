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
    module AttachmentPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :project, :cms
          alias_method_chain :container, :cms
          alias_method_chain :thumbnail, :cms
        end
      end


      module InstanceMethods
        def container_with_cms
          return CmsSite.instance if container_type == 'CmsSite'
          container_without_cms
        end

        def project_with_cms
          if container.respond_to?(:project)
            container.try(:project)
          else
            Project.new
          end
        end

        def thumbnail_with_cms(options={})
          if thumbnailable? && readable?
            size = options[:size].to_i
            if size > 0
              # Limit the number of thumbnails per image
              # size = (size / 50) * 50
              # Maximum thumbnail size
              # size = 800 if size > 800
            else
              size = Setting.thumbnails_size.to_i
            end
            size = 100 unless size > 0
            target = File.join(self.class.thumbnails_storage_path, "#{id}_#{digest}_#{size}.thumb")

            begin
              Redmine::Thumbnail.generate(self.diskfile, target, size)
            rescue => e
              logger.error "An error occured while generating thumbnail for #{disk_filename} to #{target}\nException was: #{e.message}" if logger
              return nil
            end
          end
        end


      end

    end
  end
end

unless Attachment.included_modules.include?(RedmineCMS::Patches::AttachmentPatch)
  Attachment.send(:include, RedmineCMS::Patches::AttachmentPatch)
end
