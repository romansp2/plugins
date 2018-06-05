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

#encoding: utf-8
module RedmineCms
  module Liquid
    module Tags
      module Paginate
        class Paginate < ::Liquid::Block
          # example:
          #   {% paginate users.all by 5 %}{{ paginate | default_pagination }}{% endpaginate %}
          # paginate contacts by 20
          # paginate contacts by settings.pagination_limit
          Syntax = /(#{::Liquid::VariableSignature}+)\s+by\s+(\d+|#{::Liquid::VariableSignature}+)/

          def initialize(tag_name, markup, tokens)
            if markup =~ Syntax
              @collection_name = $1
              @size_or_variable = $2
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'paginate' - Valid syntax: paginate [collection] by [size]")
            end
            super
          end

          def render(context)
            @size = ((@size_or_variable =~ /^\d+$/ && @size_or_variable) || context[@size_or_variable]).to_i
            collection = context[@collection_name] or return ''
            current_page = (context['current_page'] || 1).to_i
            items = collection.size
            pages = (items + @size -1) / @size
            in_page_collection = collection[(current_page-1)*@size, @size] or return ''
            collection.reject! {|item| !in_page_collection.include?(item)}

            context.stack do

              context['paginate'] = {
                'page_size'  => @size,
                'current_page'  => current_page,
                'current_offset'  => (current_page - 1) * @size,
                'pages'  => pages,
                'items'  => items,
              }
              if current_page > 1
                context['paginate']['previous'] = { 'url' => "?page=#{current_page - 1}", 'title' => 'Previous' }
              end
              query_param = context['q'] ? "&q=#{context['q']}" : ""
              context['paginate']['parts'] = (1..pages).map do |page|
                { 'url' => "?page=#{page}#{query_param}", 'title' => page, 'is_link' => (page != current_page) }
              end
              if current_page < pages
                context['paginate']['next'] = { 'url' => "?page=#{current_page + 1}#{query_param}", 'title' => 'Next' }
              end

              super
            end
          end

        end
      end
      ::Liquid::Template.register_tag('paginate'.freeze, Paginate::Paginate)

    end
  end
end
