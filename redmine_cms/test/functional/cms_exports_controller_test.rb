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

class CmsExportsControllerTest < ActionController::TestCase
  fixtures :projects, :users

  RedmineCMS::TestCase.create_fixtures([:cms_layouts, :cms_snippets, :cms_pages, :cms_parts,
                                        :cms_page_fields, :cms_menus, :cms_content_versions])

  def test_should_display_content_select_page
    @request.session[:user_id] = 1
    get :new, :object_type => 'cms_page', :id => 2
    assert_response :success
    assert_select '#cms_export_attachment_content', 1
  end

  def test_should_export_page_with_content_url
    @request.session[:user_id] = 1
    CmsPage.find(2).attachments << test_attachment
    post :create, :object_type => 'cms_page', :id => 2, :cms_export => { :attachment_content => 0 }
    assert_response :success
    assert_equal 'text/yaml; header=present', response.content_type
    # Page
    assert response.body.match('page_name: page_002')
    assert response.body.match('content: v3 for page2')
    assert response.body.match('parent_name: page_001')
    assert response.body.match('layout_name: layout_1')
    # Part
    assert response.body.match('parts:')
    assert response.body.match('name: header')
    assert response.body.match('part_type: header')
    assert response.body.match('description: Page 2 header')
    # Field
    assert response.body.match('fields:')
    assert response.body.match('name: Page 2 Field 1')
    assert response.body.match('content: field 3 content')
    # Attachment
    assert response.body.match('attachments:')
    assert response.body.match('filename: test.txt')
    assert response.body.match('content_type: text/plain')
    assert response.body.match(/file_url: .+test\.txt/)
  end

  def test_should_export_page_with_included_content
    @request.session[:user_id] = 1
    CmsPage.find(2).attachments << test_attachment
    post :create, :object_type => 'cms_page', :id => 2, :cms_export => { :attachment_content => 1 }
    assert_response :success
    assert_equal 'text/yaml; header=present', response.content_type
    # Page
    assert response.body.match('page_name: page_002')
    assert response.body.match('content: v3 for page2')
    assert response.body.match('parent_name: page_001')
    assert response.body.match('layout_name: layout_1')
    # Part
    assert response.body.match('parts:')
    assert response.body.match('name: header')
    assert response.body.match('part_type: header')
    assert response.body.match('description: Page 2 header')
    # Field
    assert response.body.match('fields:')
    assert response.body.match('name: Page 2 Field 1')
    assert response.body.match('content: field 3 content')
    # Attachment
    assert response.body.match('attachments:')
    assert response.body.match('filename: test.txt')
    assert response.body.match('content_type: text/plain')
    assert response.body.match(/file_content: /)
  end

  def test_should_export_layout
    @request.session[:user_id] = 1
    CmsLayout.find(1).attachments << test_attachment
    post :create, :object_type => 'cms_layout', :id => 1, :cms_export => { :attachment_content => 0 }
    assert_response :success
    assert_equal 'text/yaml; header=present', response.content_type
    # Layout
    assert response.body.match('name: layout_1')
    assert response.body.match('content: Layout 1 body')
    assert response.body.match('content_type: text/html')
    # Attachment
    assert response.body.match('attachments:')
    assert response.body.match('filename: test.txt')
    assert response.body.match('content_type: text/plain')
    assert response.body.match(/file_url: .+test\.txt/)
  end

  def test_should_export_snippet
    @request.session[:user_id] = 1
    CmsSnippet.find(1).attachments << test_attachment
    post :create, :object_type => 'cms_snippet', :id => 1, :cms_export => { :attachment_content => 0 }
    assert_response :success
    assert_equal 'text/yaml; header=present', response.content_type
    # Snippet
    assert response.body.match('name: snippet_001')
    assert response.body.match('content: Content for snippet 001')
    assert response.body.match('description for snippet 001')
    # Attachment
    assert response.body.match('attachments:')
    assert response.body.match('filename: test.txt')
    assert response.body.match('content_type: text/plain')
    assert response.body.match(/file_url: .+test\.txt/)
  end
end
