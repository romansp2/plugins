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

class CmsImportsControllerTest < ActionController::TestCase
  fixtures :projects, :users

  RedmineCMS::TestCase.create_fixtures([:cms_layouts, :cms_snippets, :cms_pages, :cms_parts,
                                        :cms_page_fields, :cms_menus, :cms_content_versions])

  def test_should_import_page_with_nested_objects
    @request.session[:user_id] = 1
    page_file = Rack::Test::UploadedFile.new(redmine_cms_fixture_files_path + 'page.yaml', 'text/yaml')
    post :create, :object_type => 'cms_page', :cms_import => { :object_type => 'cms_page', :file => page_file }
    assert_response :success
    imported_page = CmsPage.last
    assert_equal 'imported_page', imported_page.name
    assert_equal CmsLayout.where(:name => 'layout_1').first, imported_page.layout
    assert_equal 1, imported_page.parts.count
    assert_equal 'imported_page_part', imported_page.parts.first.name
    assert_equal 1, imported_page.fields.count
    assert_equal 'imported_page_field', imported_page.fields.first.name
    assert_equal 1, imported_page.attachments.count
    assert_equal 'test.vcf', imported_page.attachments.first.filename
  end

  def test_should_returns_error_if_page_existed_and_no_rewrite
    @request.session[:user_id] = 1
    page_file = Rack::Test::UploadedFile.new(redmine_cms_fixture_files_path + 'exist_page.yaml', 'text/yaml')
    post :create, :object_type => 'cms_page', :cms_import => { :object_type => 'cms_page', :file => page_file, :rewrite => 0 }
    assert_response :success
    assert response.body.match('Imported page already exists')
  end

  def test_should_update_existed_page_with_rewrite
    @request.session[:user_id] = 1
    page_file = Rack::Test::UploadedFile.new(redmine_cms_fixture_files_path + 'exist_page.yaml', 'text/yaml')
    post :create, :object_type => 'cms_page', :cms_import => { :object_type => 'cms_page', :file => page_file, :rewrite => 1 }
    assert_response :success
    existed_page = CmsPage.where(:name => 'existed_page').first
    existed_part = existed_page.parts.last
    assert_equal 'Updated page content', existed_page.content
    assert_equal nil, existed_page.layout
    assert_equal 1, existed_page.version

    assert_equal 'updated part content', existed_part.content
    assert_equal true, existed_part.is_cached
    assert_equal 1, existed_part.version
  end

  def test_should_import_snippet
    @request.session[:user_id] = 1
    snippet_file = Rack::Test::UploadedFile.new(redmine_cms_fixture_files_path + 'snippet.yaml', 'text/yaml')
    post :create, :object_type => 'cms_snippet', :cms_import => { :object_type => 'cms_snippet', :file => snippet_file }
    assert_response :success
    imported_snippet = CmsSnippet.last
    assert_equal 'imported_snippet', imported_snippet.name
    assert_equal 1, imported_snippet.attachments.count
    assert_equal 'test.vcf', imported_snippet.attachments.first.filename
  end

  def test_should_import_layout
    @request.session[:user_id] = 1
    layout_file = Rack::Test::UploadedFile.new(redmine_cms_fixture_files_path + 'layout.yaml', 'text/yaml')
    post :create, :object_type => 'cms_layout', :cms_import => { :object_type => 'cms_layout', :file => layout_file }
    assert_response :success
    imported_layout = CmsLayout.last
    assert_equal 'imported_layout', imported_layout.name
    assert_equal 1, imported_layout.attachments.count
    assert_equal 'test.vcf', imported_layout.attachments.first.filename
  end
end
