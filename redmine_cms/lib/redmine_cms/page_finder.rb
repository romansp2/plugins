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
  module Pages
    class Finder
      def self.find(path)
        self.new(path).find
      end

      def initialize(path)
        @path = path
      end

      def find
        # With slugs scoped to the parent page we need to find a page by its full path.
        # For example with about/example we would need to find 'about' and then its child
        # called 'example' otherwise it may clash with another page called /example.
        page = parent_page
        while page && path_segments.any? do
          page = next_page(page)
        end
        page
      end

      private

      attr_accessor :path

      def path_segments
        @path_segments ||= path.split('/').select(&:present?)
      end

      def parent_page
        parent_page_segment = path_segments.shift
        CmsPage.where(:slug => parent_page_segment, :parent_id => nil).first
      end

      def next_page(page)
        slug = path_segments.shift
        page.children.find_by_slug(slug)
      end

    end
  end
end
