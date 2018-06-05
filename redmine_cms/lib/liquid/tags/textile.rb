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
      module Textile

        # Render textile markup inside given block
        #
        #   {% textile %}
        #    h1. Title
        #
        #    * one
        #    * two
        #    * three
        #
        #   {% endtextile %}
        #
        class Textile < ::Liquid::Block
          include ApplicationHelper
          include ActionView::Helpers::SanitizeHelper

          FullTokenPossiblyInvalid = /^(.*)#{::Liquid::TagStart}\s*(\w+)\s*(.*)?#{::Liquid::TagEnd}$/o

          def parse(tokens)
            @nodelist ||= []
            @nodelist.clear
            while token = tokens.shift
              if token =~ FullTokenPossiblyInvalid
                @nodelist << $1 if $1 != ""
                if block_delimiter == $2
                  end_tag
                  return
                end
              end
              @nodelist << token if not token.empty?
            end
          end

          def render(context)
            options = {}
            cms_object = context.registers[:cms_object]
            options[:attachments] = cms_object.attachments if cms_object.respond_to?(:attachments)
            textilizable(render_all(@nodelist, context), options)
          end
        end
      end

      ::Liquid::Template.register_tag('textile'.freeze, Textile::Textile)

    end
  end
end
