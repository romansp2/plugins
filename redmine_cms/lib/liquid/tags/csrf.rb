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
      module Csrf

        class Base < ::Liquid::Tag
          def render(context)
            view = context.registers[:listener].view_context
            if view
              render_csrf(view)
            else
              ''
            end
          end
        end

        class Param < Base
          def render_csrf(view)
            %(<input type="hidden" name="#{view.request_forgery_protection_token}" value="#{view.form_authenticity_token}" />)
          end
        end

        class Meta < Base
          def render_csrf(view)
            view.csrf_meta_tag
          end

        end

      end

      ::Liquid::Template.register_tag('csrf_param'.freeze, Csrf::Param)
      ::Liquid::Template.register_tag('csrf_meta'.freeze, Csrf::Meta)

    end
  end
end
