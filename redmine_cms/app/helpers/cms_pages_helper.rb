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

module CmsPagesHelper
   def page_breadcrumb(page)
    return unless page.parent
    pages = page.ancestors.reverse
    pages << page
    links = pages.map {|ancestor| link_to(h(ancestor.title), cms_page_path(ancestor))}
    breadcrumb links
  end

  def pages_options_for_select(pages)
    options = []
    CmsPage.page_tree(pages) do |page, level|
      label = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
      label << page.name
      options << [label, page.id]
    end
    options
  end

  def set_locale
    if RedmineCms.use_localization?
      if lang = params[:path].to_s[/^\/?(#{CmsSite.locales.join('|')})+(\/|$)/, 1]
        CmsSite.language = lang
      elsif params[:locale]
        CmsSite.language = params[:locale]
      elsif session[:cms_locale]
        CmsSite.language = session[:cms_locale]
      else
        CmsSite.language = Setting.default_language
      end
      session[:cms_locale] = CmsSite.language
    end
  end

  def change_page_status_link(page)
    url = {:controller => 'cms_pages', :action => 'update', :id => page, :page => params[:page], :status => params[:status], :tab => nil}

    if page.active?
      link_to l(:button_lock), url.merge(:page => {:status_id => RedmineCms::STATUS_LOCKED}), :method => :put, :class => 'icon icon-lock'
    else
      link_to l(:button_unlock), url.merge(:page => {:status_id => RedmineCms::STATUS_ACTIVE}), :method => :put, :class => 'icon icon-unlock'
    end
  end

  def link_to_add_page_fields(name, f, association, options={})
    new_object = CmsPageField.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render "page_field_form", :f => builder
    end
    link_to_function(name, "add_page_fields(this, '#{association}', '#{escape_javascript(fields)}')", options)
  end

  def link_to_remove_page_fields(name, f, options={})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_page_fields(this)", options)
  end

  def page_tree(pages, &block)
    CmsPage.page_tree(pages, &block)
  end

end
