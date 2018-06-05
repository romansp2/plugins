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
      module Html

        # Find fist tag in page
        #
        # input - html content
        #
        # Returns array of tag contents
        def html_tags(input, html_tag)
          input.to_s.scan(%r{<#{html_tag}[^>]*>(.*?)<\/#{html_tag}>}).flatten
        end

        def strip_tags(input)
          ActionController::Base.helpers.strip_tags(input)
        end


      end # module ArrayFilters
    end
  end

  ::Liquid::Template.register_filter(RedmineCms::Liquid::Filters::Html)
end
