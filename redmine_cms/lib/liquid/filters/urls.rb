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
      module Urls
        include Rails.application.routes.url_helpers

        # example:
        #   {{ 'page1:image.png' | attachment_url: 'absolute:true' }}
        def attachment_url(input, *args)
          return '' if input.blank?
          options = args_to_options(args)
          attachment = get_attachment_drop(input)
          return "" if attachment.blank?
          attachment.asset_url(options)
        end

        # example:
        #   {{ 'image.png' | thumbnail_url: 'size:100', 'absolute:true' }}
        def thumbnail_url(input, *args)
          return '' if input.blank?
          options = args_to_options(args)
          attachment = get_attachment_drop(input)
          return '' if attachment.blank?
          attachment.thumbnail_url(options)
        end


      # example:
        #
        #   {{ 'page_name:main_script' | part_url }}
        #
        #
        #   Current page part
        #   {{ ':main_script' | part_url }}
        #
        def part_url(input, *args)
          return '' if input.blank?
          options = args_to_options(args)
          part_drop = get_part_drop(input)
          return '' if part_drop.blank?
          part_drop.url(options)
        end


        # example:
        #
        #   {{ 'main' | page_url }} => '/pages/main'
        #   {{ 'main' | page_url: 'absolute:true' }} => https://localhost:3000/pages/main
        #   {{ 'main' | page_url: 'absolute:true', 'localized:true'}} => https://localhost:3000/pages/de/main
        #
        #    Result:
        #
        #   /pages/main
        def page_url(input, *args)
          return '' if input.blank?
          page_drop = get_page_drop(input)
          return '' if page_drop.blank?
          options = args_to_options(args)
          page_drop.url(options)
        end

      end
    end
  end

  ::Liquid::Template.register_filter(RedmineCms::Liquid::Filters::Urls)
end
