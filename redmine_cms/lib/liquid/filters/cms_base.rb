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
  module Liquid
    module Filters
      module CmsBase

        protected

        def get_attachment_drop(input)
          return if input.blank?
          return input if input.is_a?(CmsAttachmentDrop)
          cms_object, filename = get_cms_object(input)
          cms_object = cms_object.page if cms_object.is_a?(CmsPart)
          attachment = cms_object.attachments.where(:filename => filename).last
          return if attachment.blank?
          CmsAttachmentDrop.new attachment
        end

        def get_cms_object(input="")
          if input.match(/(^\S+)?:(.+)$/)
            page_object = $2
            page = page_object && $1 ? CmsPage.find_by_name($1) : CmsSite.instance
          end
          page ||= @context.registers[:cms_object]
          page_object ||= input
          [page, page_object]
        end

        def get_part_drop(input)
          return if input.blank?
          return input if input.is_a?(PartDrop)
          page, part_name = get_cms_page(input)
          return '' if page.blank? || !page.is_a?(CmsPage)
          part = page.parts.active.find_part(part_name)
          return if part.blank?
          PartDrop.new part
        end

        def get_page_drop(input)
          return if input.blank?
          return input if input.is_a?(PageDrop)
          page = CmsPage.find_by_name(input)
          return if page.blank?
          PageDrop.new page
        end

        def get_cms_page(input="")
          if input.match(/(^\S+)?:(.+)$/)
            page_object = $2
            page = CmsPage.find_by_name($1) if page_object && $1
          end
          page ||= @context.registers[:page]
          page_object ||= input
          [page, page_object]
        end

      end
      ::Liquid::Template.register_filter(RedmineCms::Liquid::Filters::CmsBase)

    end
  end
end
