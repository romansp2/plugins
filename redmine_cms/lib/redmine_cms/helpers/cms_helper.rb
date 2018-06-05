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

module RedmineCms
  module CmsHelper
    def favicon_cms
      if current_theme && current_theme.images.include?('favicon.ico')
        "<link rel='shortcut icon' href='#{current_theme.image_path('/favicon.ico')}' />".html_safe
      else
        favicon
      end
    end

    def jquery_tag
      jquery_dir = File.join(Rails.root, "public", "stylesheets", "jquery")
      jquery_css = File.basename(Dir[jquery_dir + "/jquery*.css"].first)
      stylesheet_link_tag "jquery/#{jquery_css}", 'application', :media => 'all'
    end

    def render_account_menu
      s = "<ul>"
      if User.current.logged?
        s << "<li>#{avatar(User.current, :size => "16").to_s.html_safe + link_to_user(User.current, :format => :username) }"
          links = []
          menu_items_for(:account_menu) do |node|
            links << render_menu_node(node)
          end
          s << (links.empty? ? "" : content_tag('ul', links.join("\n").html_safe, :class => "menu-children"))

        s << "</li>"
      else
        s << "<li>#{link_to l(:label_login), signin_path}</li>"
      end
      s << "</ul>"
      s.html_safe
    end

    def render_page(page)
      s = "".html_safe
      s << cached_render_part(page)
      page.parts.order(:position).active.each do |page_part|
        case page_part.name
        when "content"
          s << cached_render_part(page_part)
        else
          content_for(page_part.name.to_sym, cached_render_part(page_part))
        end
      end
      s
    end

    def cached_render_part(part)
      if part.respond_to?(:is_cached) && part.is_cached?
        Rails.cache.fetch(part, :expires_in => RedmineCms.cache_expires_in.minutes) {render_part(part)}
      else
        render_part(part)
      end
    end

    def layout_html_head_parts
      @layout_html_head_parts = CmsPart.where(:part_type => "layout_html_head_part").order(:name)
    end

    def layout_body_top_parts
      @layout_body_top_parts = CmsPart.where(:part_type => "layout_body_top_part").order(:name)
    end

    def layout_body_bottom_parts
      @layout_body_bottom_parts = CmsPart.where(:part_type => "layout_body_bottom_part").order(:name)
    end

    def layout_base_sidebar_parts
      @layout_base_sidebar_parts = CmsPart.where(:part_type => "layout_base_sidebar").order(:name)
    end

    def render_liquid(content, part=nil)
      assigns = {}
      assigns['users'] = UsersDrop.new(User.sorted)
      assigns['projects'] = ProjectsDrop.new(Project.visible.order(:name))
      assigns['newss'] = NewssDrop.new(News.visible.order("#{News.table_name}.created_on"))
      assigns['current_page'] = self.respond_to?(:params) && self.params[:page] || 1
      assigns['page'] = PageDrop.new(@page) if @page
      assigns['pages'] = PagesDrop.new(CmsPage.where(nil))
      assigns['params'] = self.params if self.respond_to?(:params)
      assigns['request'] = RequestDrop.new(request) if self.respond_to?(:request)
      assigns['now'] = Time.now
      assigns['today'] = Date.today

      CmsVariable.all.each do |var|
        assigns["cms_variable_#{var.name}"] = var.value
      end

      registers = {}
      registers[:part] = part if part
      registers["projects"] = ProjectsDrop.new(Project.order(:name))
      begin
        ::Liquid::Template.parse(content).render(::Liquid::Context.new({}, assigns, registers)).html_safe
      rescue => e
        e.message
      end
    end

    def render_part(part)
      s = render_liquid(part.content, part)
      s = RedmineCms::Textile::Formatter.new(s).to_html.html_safe if part.filter_id == "textile"
      s = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :tables => true).render(s).html_safe if part.filter_id == "markdown"
      s
    end

    def filter_options_for_select(selected = nil)
      options_for_select([['HTML', '', { 'data-mode' => 'htmlmixedliquid' }]] + TextFilter.descendants.map { |f| [f.filter_name, f.filter_name, { 'data-mode' => f.mine_type }] }, selected)
    end
  end
end

ActionView::Base.send :include, RedmineCms::CmsHelper
::Liquid::Strainer.send :include, RedmineCms::CmsHelper
