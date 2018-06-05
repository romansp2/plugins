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

class ScssFilter < TextFilter

  def self.mine_type
    'scssmixedliquid'
  end

  def filter(text, cms_object)
    begin
      options = {:syntax => :scss, :style => Rails.env.production? ? :compressed : :nested}
      options[:style] = :compact if Rails.env.production?

      Sass::Engine.new(text, options).render
    rescue Sass::SyntaxError
      "Syntax Error at line #{$!.sass_line}: " + $!.to_s
    end
  end
end
