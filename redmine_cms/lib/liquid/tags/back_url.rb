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
    module Tags
      module BackUrl

        class Base < ::Liquid::Tag
          def render(context)
            return '' if context.registers[:listener].blank?
            view = context.registers[:listener].view_context
            params = view.request.params
            url = params[:back_url]
            if url.nil? && referer = view.request.env['HTTP_REFERER']
              url = CGI.unescape(referer.to_s)
            end
            unless url.blank?
              render_url(url)
            else
              ''
            end
          end

        end

        class BackUrlField < Base
          def render_url(url)
            %(<input type="hidden" name="back_url" value="#{url}" />)
          end
        end

        class BackUrl < Base
          def render_url(url)
            url
          end
        end

      end

      ::Liquid::Template.register_tag('back_url_field'.freeze, BackUrl::BackUrlField)
      ::Liquid::Template.register_tag('back_url'.freeze, BackUrl::BackUrl)

    end
  end
end
