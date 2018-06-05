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

module CmsHelper
  def cms_change_status_link(obj_name, obj)
    return unless obj.respond_to?(:status_id)
    url = {:controller => "cms_#{obj_name}s", :action => 'update', :id => obj, obj_name.to_sym => params[obj_name.to_sym], :status => params[:status], :back_url => url_for(params)}

    if obj.active?
      link_to l(:button_lock), url.merge(obj_name.to_sym => {:status_id => RedmineCms::STATUS_LOCKED}, :unlock => true), :method => :put, :remote => :true, :class => 'icon icon-lock'
    else
      link_to l(:button_unlock), url.merge(obj_name.to_sym => {:status_id => RedmineCms::STATUS_ACTIVE}, :unlock => true), :method => :put, :remote => :true, :class => 'icon icon-unlock'
    end
  end

  def cms_visibilities_for_select(selected = nil, options={})
    grouped_options = {}
    grouped_options[l(:label_user_plural)] = [[l(:field_admin), '']] if options[:admin]
    grouped_options[l(:label_role_plural)] = [["Public", 'public'], ["Logged", 'logged']] unless options[:only_groups]
    grouped_options[l(:label_group_plural)] = Group.where(:type => 'Group').map{|g| [g.name, g.id]}
    grouped_options_for_select(grouped_options, selected)
  end

  def cms_reorder_links(name, url, method = :post)
    link_to(image_tag('2uparrow.png', :alt => l(:label_sort_highest)),
            url.merge({"#{name}[move_to]" => 'highest'}),
            :remote => true,
            :method => method, :title => l(:label_sort_highest)) +
    link_to(image_tag('1uparrow.png',   :alt => l(:label_sort_higher)),
            url.merge({"#{name}[move_to]" => 'higher'}),
            :remote => true,
            :method => method, :title => l(:label_sort_higher)) +
    link_to(image_tag('1downarrow.png', :alt => l(:label_sort_lower)),
            url.merge({"#{name}[move_to]" => 'lower'}),
            :remote => true,
            :method => method, :title => l(:label_sort_lower)) +
    link_to(image_tag('2downarrow.png', :alt => l(:label_sort_lowest)),
            url.merge({"#{name}[move_to]" => 'lowest'}),
            :remote => true,
            :method => method, :title => l(:label_sort_lowest))
  end

  def code_mirror_tags
    s = ''
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/lib/codemirror')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/lib/emmet')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/addon/mode/overlay')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/addon/search/search')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/addon/search/searchcursor')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/addon/dialog/dialog')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/addon/comment/comment')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/htmlmixed/htmlmixed')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/css/css')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/liquid/liquid')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/xml/xml')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/javascript/javascript')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/mode/textile/textile')
    s << javascript_include_tag('/plugin_assets/redmine_cms/codemirror/keymap/sublime')
    s << stylesheet_link_tag('/plugin_assets/redmine_cms/codemirror/lib/codemirror')
    s << stylesheet_link_tag('/plugin_assets/redmine_cms/codemirror/theme/ambiance')
    s << stylesheet_link_tag('/plugin_assets/redmine_cms/codemirror/mode/liquid/liquid')
    s.html_safe
  end

  def cms_layouts_for_select(options = {})
    cms_layouts = []
    cms_layouts << [l(:label_cms_redmine_layout), ''] unless options[:only_cms]
    cms_layouts += CmsLayout.order(:name).map{|l| [l.name, l.id]} if CmsLayout.any?
    cms_layouts
  end

  def cms_statuses_for_select(options = {})
    [[l(:label_cms_status_locked), RedmineCms::STATUS_LOCKED], [l(:label_cms_status_active), RedmineCms::STATUS_ACTIVE]]
  end

  def link_to_cms_attachments(container, options = {})
    options.assert_valid_keys(:author, :thumbnails)

    attachments = container.attachments.preload(:author).to_a
    if attachments.any?
      options = {
        :editable => RedmineCms.allow_edit?,
        :deletable => RedmineCms.allow_edit?,
        :author => true
      }.merge(options)
      render :partial => 'cms_attachments/links',
        :locals => {
          :container => container,
          :attachments => attachments,
          :options => options,
          :thumbnails => (options[:thumbnails] && Setting.thumbnails_enabled?)
        }
    end
  end

  def cms_thumbnail_tag(attachment)
    link_to image_tag(cms_thumbnail_path(attachment, 100, attachment.filename)),
      download_named_asset_path(attachment, attachment.filename),
      :title => attachment.filename
  end

  # Renders the project quick-jump box
  def render_page_jump_box
    return unless User.current.logged?
    pages = CmsPage.active.to_a
    if pages.any?
      options =
        ("<option value=''>#{ l(:label_cms_jump_to_a_page) }</option>" +
         '<option value="" disabled="disabled">---</option>').html_safe
      pages_name_options_for_select(pages, :label => 'name').each do |o|
        tag_options = {:value => edit_cms_page_path(:id => o[1])}
        tag_options[:selected] = @page && o[1] == @page.name ? 'selected' : nil
        options << content_tag('option', o[0], tag_options)
      end
      content_tag( :span, nil, :class => 'jump-box-arrow') +
      select_tag('project_quick_jump_box', options, :onchange => 'if (this.value != \'\') { window.location = this.value; }')
    end
  end


  def pages_name_options_for_select(pages, options = {})
    pages_name_options = []
    CmsPage.page_tree(pages) do |page, level|
      label = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
      label << (options[:label] == 'name' ? page.name : page.title)
      pages_name_options << [label, page.name]
    end
    pages_name_options
  end

  def cms_title(*args)
    strings = args.map do |arg|
      if arg.is_a?(Array) && arg.size >= 2
        link_to(*arg)
      else
        h(arg.to_s)
      end
    end
    content_tag('h2', strings.join(' &#187; ').html_safe)
  end
end
