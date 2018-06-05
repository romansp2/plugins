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
  module Liquid
    module Tags
      module Render
        # RenderPage allows render page with parts inside layoyt
        #
        # Simply render page content
        #
        #   {% content %}
        #
        class PageContent < ::Liquid::Tag
          def render(context)
            page = context.registers[:page]
            raise ArgumentError, "Page not found in Liquid context" if page.blank?
            context.stack do
              page.context = context
              page.render_page
            end
          end
        end

        # Render 'sidebar' part of current page:
        #
        #   {% part_content 'sidebar' %}
        #
        class PartContent < ::Liquid::Tag
          Syntax = /(#{::Liquid::QuotedFragment}+)?/o

          def initialize(tag_name, markup, tokens)
            super
            if markup =~ Syntax
              @part_var = ::Liquid::Variable.new($1)
            else
              raise SyntaxError, "Syntax error {% part_content 'part_name' %}"
            end
          end

          def render(context)
            part_name = @part_var.render(context)
            page = context.registers[:page]
            return context.registers["#{part_name}_content"] if page.name == 'empty page'
            page.context = context
            return '' if page.blank?
            part = page.parts.detect{|p| p.name == part_name}
            return '' if part.blank?
            context.stack do
              part.active? ? page.render_part(part) : ''
            end
          end
        end

        # Render 'news' snippet:
        #
        #   {% render_snippet 'news' %}
        #
        class RenderSnippet < ::Liquid::Tag
          Syntax = /(#{::Liquid::QuotedFragment}+)?/o

          def initialize(tag_name, markup, tokens)
            super
            if markup =~ Syntax
              @param_var = ::Liquid::Variable.new($1)
            else
              raise SyntaxError, "Syntax error {% render_snippet 'snippet_name' %}"
            end
          end

          def render(context)
            page = context.registers[:page]
            snippet_name = @param_var.render(context)
            return context["#{snippet_name}_snippet_content"] unless page
            page.context = context
            snippet = CmsSnippet.where(:name => snippet_name).first
            raise ArgumentError, """render_snippet '#{snippet_name}'"": no such snippet '#{snippet_name}'" if snippet.blank?
            context.stack do
              page.render_part(snippet)
            end
          end
        end

        # Render 'filename.css' attachment:
        #
        #   {% render_file 'filename.css' %}
        #
        class RenderFile < ::Liquid::Tag
          Syntax = /(#{::Liquid::QuotedFragment}+)?/o

          def initialize(tag_name, markup, tokens)
            super
            if markup =~ Syntax
              @param_var = ::Liquid::Variable.new($1)
            else
              raise SyntaxError, "Syntax error {% render_file 'attachment_name' %}"
            end
          end

          def render(context)
            cms_object = context.registers[:cms_object]
            attachment_name = @param_var.render(context)
            attachment = cms_object && cms_object.respond_to?(:attachments) && cms_object.attachments.find_by_filename(attachment_name)
            if attachment && attachment.readable? && (attachment.is_text? || attachment.content_type.include?('javascript'))
              File.new(attachment.diskfile, "rb").read.to_s.force_encoding("UTF-8")
            else
              ''.freeze
            end
          end
        end

        # Check page and page content presents
        #
        #   {% if_part_content 'sidebar' %}
        #
        #   {% endif_part_content %}
        #
        class IfPartContent < ::Liquid::Block
          Syntax = /(#{::Liquid::QuotedFragment}+)?/o


          def initialize(tag_name, markup, tokens)
            super
            if markup =~ Syntax
              @part_name = $1[1..-2].split('/'.freeze).last
            else
              raise SyntaxError, "[if_part_content] Syntax error {% if_part_content 'part_name' %} {% endif_part_content %}"
            end
          end

          def render(context)
            context.stack do
              output = super
              page = context.registers[:page]
              part = page.parts.where(:name => @part_name).first if page
              if (page && part && !part.content.blank?) || context["#{@part_name}_content"]
                output
              else
                ''.freeze
              end
            end
          end
        end

      end

      ::Liquid::Template.register_tag('if_part_content'.freeze, Render::IfPartContent)
      ::Liquid::Template.register_tag('content'.freeze, Render::PageContent)
      ::Liquid::Template.register_tag('part_content'.freeze, Render::PartContent)
      ::Liquid::Template.register_tag('render_snippet'.freeze, Render::RenderSnippet)
      ::Liquid::Template.register_tag('render_file'.freeze, Render::RenderFile)
    end
  end
end
