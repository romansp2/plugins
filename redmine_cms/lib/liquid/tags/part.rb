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
      module Part
        # Iclude part content
        #
        #   {% include_part 'part' %}
        #   {% include_part 'main:part' %}
        #   {% include_part page.parts.first %}
        class IncludePart < ::Liquid::Include
          private

          def read_template_from_file_system(context)
            part_path = ::Liquid::Variable.new(@template_name).render(context)
            return part_path.content if part_path.is_a?(PartDrop)

            if part_path.match(/(^\S+)?:(.+)$/)
              part_name = $2
              page = CmsPage.find_by_name($1) if part_name && $1
            end
            part_name ||= part_path
            page ||= context.registers[:page]
            part = page.parts.detect{|p| p.name == part_name}
            return unless part
            raise ::Liquid::FileSystemError, "Part with name '#{part_path}' was not found" unless part
            part.content

          end

        end

      end

      ::Liquid::Template.register_tag('include_part'.freeze, Part::IncludePart)
    end
  end
end
