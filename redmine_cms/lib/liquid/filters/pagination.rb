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

module RedmineCrm
  module Liquid
    module Filters
      module Pagination
        # example:
        #   {% paginate users.all by 5 %}{{ paginate | default_pagination }}{% endpaginate %}
        def default_pagination(paginate)
          current_page = paginate['current_page']
          pages = paginate['pages']
          result = ''
          if paginate['previous']
            result += %Q( <span class="prev"><a href="#{paginate['previous']['url']}">&#171; #{paginate['previous']['title']}</a></span>)
          end
          paginate['parts'].each do |part|
            page =  part['title']
            if page == (current_page + 3) and page != pages
              result += %Q( <span class="deco">...</span>)
            elsif page > (current_page + 3) and page != pages #省略
            elsif page == (current_page - 3) and page != 1
              result += %Q( <span class="deco">...</span>)
            elsif page < (current_page - 3) and page != 1 #省略
            else
              if part['is_link']
                result += %Q( <span class="page"><a href="#{part['url']}">#{page}</a></span>)
              else
                result += %Q( <span class="page current">#{page}</span>)
              end
            end
          end
          if paginate['next']
            result += %Q( <span class="next"><a href="#{paginate['next']['url']}">#{paginate['next']['title']} &#187;</a></span>)
          end
          result
        end

      end
    end
  end

  ::Liquid::Template.register_filter(RedmineCrm::Liquid::Filters::Pagination)
end
