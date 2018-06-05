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
      module Tags
        include ActionView::Helpers::TagHelper

        # example:
        #
        #   {{ 'main' | page_link: 'translated:true', 'class:link arrow' }}
        #
        def page_link(input, *args)
          page_drop = get_page_drop(input)
          options = args_to_options(args)
          tag_options = options.slice!(:absolute, :localized)
          page_url = page_drop.url(options)
          return '' if page_url.blank?
          content_tag(:a, page_drop.title.blank? ? page_drop.name : page_drop.title, tag_options.merge(:href => page_url))
        end

        # example:
        #   {{ 'image.png' | thumbnail_tag: 'size:100', 'title:A title', 'width:100px', 'height:200px'  }}
        def thumbnail_tag(input, *args)
          attachment = get_attachment_drop(input)
          thumbnail_url = thumbnail_url(attachment, args)
          return '' if thumbnail_url.blank?
          options = args_to_options(args)
          options[:alt] ||= attachment.description.blank? ? attachment.filename : attachment.description
          tag_options = {:src => thumbnail_url}.merge(options)
          content_tag(:img, nil, tag_options)
        end


        # example:
        #   {{ 'image.png' | image_tag: 'title:A title', 'width:100px', 'height:200px'  }}
        def image_tag(input, *args)
          attachment = get_attachment_drop(input)
          return '' if attachment.blank? || (attachment && attachment.asset_url.blank?)
          options = args_to_options(args)
          options[:alt] ||= attachment.description.blank? ? attachment.filename : attachment.description
          tag_options = {:src => attachment.asset_url}.merge(options)
          content_tag(:img, nil, tag_options)
        end


        # example:
        #
        #   {{ 'main_styles' | stylesheet_page_tag: 'type:text/css' }}
        #
        def stylesheet_page_tag(input, *args)
          page_drop = get_page_drop(input)
          page_url = page_url(page_drop)
          return '' if page_url.blank?
          options = args_to_options(args)
          rel = options.delete(:rel) || 'stylesheet'
          mime_type = options.delete(:type) || 'text/css'
          content_tag(:link, nil, :href => "#{page_url}.css?#{page_drop.digest}", :type => mime_type, :rel => rel)
        end

        # example:
        #
        #   {{ 'main' | javascript_page_tag: 'type:text/css' }}
        #
        def javascript_page_tag(input, *args)
          page_drop = get_page_drop(input)
          page_url = page_url(page_drop)
          return '' if page_url.blank?
          content_tag(:script, nil, :src => "#{page_url}.js?#{page_drop.digest}")
        end

       # example:
        #
        #   {{ 'page_name:main_styles' | stylesheet_part_tag: 'type:text/css' }}
        #
        #
        #   Current page part
        #   {{ ':main_styles' | stylesheet_part_tag: 'type:text/css' }}
        #
        def stylesheet_part_tag(input, *args)
          part_drop = get_part_drop(input)
          part_url = part_url(part_drop)
          return '' if part_url.blank?
          options = args_to_options(args)
          rel = options.delete(:rel) || 'stylesheet'
          mime_type = options.delete(:type) || 'text/css'
          content_tag(:link, nil, :href => "#{part_url}.css?#{part_drop.digest}", :type => mime_type, :rel => rel)
        end

       # example:
        #
        #   {{ 'page_name:main_script' | javascript_part_tag }}
        #
        #
        #   Current page part
        #   {{ ':main_script' | javascript_part_tag }}
        #
        def javascript_part_tag(input, *args)
          part_drop = get_part_drop(input)
          part_url = part_url(part_drop)
          return '' if part_url.blank?
          content_tag(:script, nil, :src => "#{part_url}.js?#{part_drop.digest}")
        end

      end
    end
  end

  ::Liquid::Template.register_filter(RedmineCms::Liquid::Filters::Tags)
end
