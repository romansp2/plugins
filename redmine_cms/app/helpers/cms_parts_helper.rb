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

module CmsPartsHelper
  def change_part_status_link(part)
    url = {:controller => 'cms_parts', :action => 'update', :id => part, :part => params[:part], :status => params[:status], :tab => nil}

    if part.active?
      link_to l(:button_lock), url.merge(:part => {:status_id => RedmineCms::STATUS_LOCKED}, :unlock => true), :method => :put, :class => 'icon icon-lock'
    else
      link_to l(:button_unlock), url.merge(:part => {:status_id => RedmineCms::STATUS_ACTIVE}, :unlock => true), :method => :put, :class => 'icon icon-unlock'
    end
  end

  def parts_type_collection
    [["Pages", [["Content", "content"],
                ["Sections", "sections"],
                ["Sidebar", "sidebar"],
                ["Header", "header"],
                ["Footer", "footer"],
                ["Header tags", "header_tags"]]],
     ["Layout", [["Layout html head", "layout_html_head_part"],
                 ["Layout sidebar top", "layout_base_sidebar"],
                 ["Layout body top", "layout_body_top_part"],
                 ["Layout body bottom", "layout_body_bottom_part"]]]]
  end

  def parts_option_for_select
    parts = CmsPart.order(:part_type).where("#{CmsPart.table_name}.part_type NOT LIKE 'layout_%'").order(:content_type)
    return "" unless parts.any?
    previous_group = parts.first.part_type
    s = "<optgroup label=\"#{ERB::Util.html_escape(parts.first.part_type)}\">".html_safe
    parts.each do |part|
      if part.part_type != previous_group
        reset_cycle
        s << '</optgroup>'.html_safe
        s << "<optgroup label=\"#{ERB::Util.html_escape(part.part_type)}\">".html_safe
        previous_group = part.part_type
      end
      s << %Q(<option value="#{ERB::Util.html_escape(part.id)}">#{part.to_s}</option>).html_safe
    end
    s << '</optgroup>'.html_safe
    s.html_safe
  end
end
