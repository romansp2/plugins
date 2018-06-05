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
      module CmsControls

        class CmsControls < ::Liquid::Tag
          def render(context)
            return "" unless RedmineCms.allow_edit?
            return "" if context.registers[:listener].blank?
            params = {}
            %{
              <a href="#{context.registers[:listener].edit_cms_page_path(context.registers[:page])}">
                <div
                    style="background-color: #000;
                    border: 2px solid #fff;
                    cursor: pointer;
                    border-radius: 30px;
                    box-shadow: rgba(0, 0, 0, 0.258824) 0px 2px 5px 0px;
                    z-index: 999;
                    width: 32px;
                    height: 32px;
                    position: fixed;
                    left: 10px;
                    bottom: 10px;">
                </div>
              </a>
            }
          end
        end
      end

      ::Liquid::Template.register_tag('cms_controls'.freeze, CmsControls::CmsControls)

    end
  end
end
