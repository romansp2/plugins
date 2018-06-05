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

class CmsLayout < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes
  include RedmineCms::Filterable

  has_many :pages, :class_name => 'CmsPage', :foreign_key => 'layout_id', :dependent => :nullify

  after_commit :expire_pages_cache

  acts_as_attachable_cms
  acts_as_versionable_cms

  validates_presence_of :name, :content

  attr_protected :id

  def expire_pages_cache
    pages.each(&:expire_cache)
  end
end
