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

class TextFilter
  attr_accessor :filter_name, :cms_object

  def filter(text, cms_object)
    text
  end

  class << self
    def inherited(subclass)
      subclass.filter_name = subclass.name.gsub(/\s*Filter$/, '')
    end

    def filter(text)
      instance.filter(text, cms_object)
    end

    def mine_type
      'htmlmixedliquid'
    end

    def descendants_names
      descendants.map { |s| s.filter_name }.sort
    end

    def find_descendant(filter_name)
      descendants.each do |s|
        return s if s.filter_name == filter_name
      end
      nil
    end

    def instance(&block)
      @instance ||= new
      block.call(@instance) if block_given?
      @instance
    end

    def method_missing(method, *args, &block)
      instance.respond_to?(method) ? instance.send(method, *args, &block) : super
    end

  end
end
