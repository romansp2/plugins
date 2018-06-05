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
      module Cacher
        # Cache page fragment
        #
        #   {% cache users.current %}
        #     {{ cached_fragment }}
        #   {% endcache %}
        #
        #   {% cache 'cache_name' %}
        #     {{ cached_fragment }}
        #   {% endcache %}
        class Cacher < ::Liquid::Block

          Syntax = /(#{::Liquid::QuotedFragment}+)?/o

          def initialize(tag_name, markup, tokens)
            super
            if markup =~ Syntax
              @key_var = ::Liquid::Variable.new($1)
            else
              raise SyntaxError, "Syntax error {% cache 'key_name' %}"
            end
          end

          def render(context)
            key = @key_var.render(context)
            page_key = "#{context.registers[:page].try(:cache_key).to_s}/#{key}/#{context.registers[:cms_object].try(:cache_key).to_s}/#{CmsSite.language}"
            Rails.cache.fetch(page_key) do
              super
            end
          end
        end


      end

      ::Liquid::Template.register_tag('cache'.freeze, Cacher::Cacher)
    end
  end
end
