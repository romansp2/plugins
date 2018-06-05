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
      module Locale

        # Returns localized page
        #
        # input - PageDrop in site or selected locale
        #
        def in_locale(page, language)
          return "" unless page.is_a?(PageDrop)
          page.in_locale(language || CmsSite.language)
        end


      end # module Locale
    end
  end

  ::Liquid::Template.register_filter(RedmineCms::Liquid::Filters::Locale)
end
