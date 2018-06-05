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

module Redmine
  module MenuManager
    module MenuHelper
      def render_menu_node(node, project=nil)
        if node.children.present? || !node.child_menus.nil?
          return render_menu_node_with_children(node, project)
        elsif allowed_node?(node, User.current, project)
          caption, url, selected = extract_node_details(node, project)
          return content_tag('li',
                               render_single_menu_node(node, caption, url, selected))
        end
      end

      def render_single_menu_node(item, caption, url, selected)
        link_to(caption.html_safe, url, item.html_options(:selected => selected))
      end

    end

    class MenuNode
      # Adds a child at given position
      # Overwrite this method for resolve conflicts with menu names
      def add_at(child, position)
        return child if find {|node| node.name == child.name}

        @children = @children.insert(position, child)
        child.parent = self
        child
      end

    end
  end
end
