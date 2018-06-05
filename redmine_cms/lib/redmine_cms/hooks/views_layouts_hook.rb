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
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      include RedmineCms::CmsHelper

      def view_layouts_base_html_head(context={})
        s = ''
        s << stylesheet_link_tag(:redmine_cms, :plugin => 'redmine_cms')
        unless RedmineCms.view_layouts_base_html_head_hook.blank?
          page = CmsPage.new(:content => RedmineCms.view_layouts_base_html_head_hook.to_s)
          s << page.process(context[:hook_caller])
        end
        s
      end

      def view_layouts_base_sidebar(context = { })
        return if RedmineCms.view_layouts_base_sidebar_hook.blank?
        page = CmsPage.new(:content => RedmineCms.view_layouts_base_sidebar_hook.to_s)
        page.process(context[:hook_caller])
      end

      def view_layouts_base_body_bottom(context = { })
        return if RedmineCms.view_layouts_base_body_bottom_hook.blank?
        page = CmsPage.new(:content => RedmineCms.view_layouts_base_body_bottom_hook.to_s)
        page.process(context[:hook_caller])
      end

    end
  end
end
