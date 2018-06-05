# encoding: utf-8
#
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

require File.expand_path('../../test_helper', __FILE__)

class CmsContentVersionTest < ActiveSupport::TestCase
  fixtures :projects, :users

  RedmineCMS::TestCase.create_fixtures([:cms_layouts, :cms_snippets, :cms_pages, :cms_parts,
                                        :cms_page_fields, :cms_menus, :cms_content_versions])

  def test_create_page_with_version
    page = CmsPage.new(:title => 'Page with history', :name => 'page_with_history', :content => 'This is content for page with history (v1)')
    page.save
    assert_equal page.content, page.versions.first.content
    assert_equal 1, page.version
    assert_equal 1, page.versions.first.version
    assert page.versions.first.current_version?
  end

  def test_create_part_with_version
    part = CmsPart.new(:part_type => 'footer', :name => 'part_with_history', :content => 'This is content for part with history (v1)', :page_id => 1)
    part.save
    assert_equal part.content, part.versions.first.content
    assert_equal 1, part.version
    assert_equal 1, part.versions.first.version
    assert part.versions.first.current_version?
  end
end
