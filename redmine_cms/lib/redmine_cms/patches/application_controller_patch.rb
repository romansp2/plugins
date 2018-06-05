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

module RedmineCMS
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          layout :set_layout
          alias_method_chain :set_localization, :cms
          alias_method_chain :render_error, :cms
          before_filter :menu_setup
          before_filter :cms_redirects
        end
      end


      module InstanceMethods
        def cms_redirects
          if request.get? && RedmineCms.redirects[request.path]
            query_params = URI.encode_www_form(request.query_parameters)
            query_params = (RedmineCms.redirects[request.path] =~ /\?/ ? '&' : '?') + query_params unless query_params.blank?
            redirect_to RedmineCms.redirects[request.path] + query_params, :status => 301 
          end
        end

        def menu_setup
          # Check the settings cache for each request
          @controller = self
          CmsMenu.check_cache
        end

        def set_layout
          if CmsRedmineLayout.find_by_action(params[:controller], params[:action]).try(:layout)
            'cms_custom'
          else
            'base'
          end
        end

        def use_layout_with_cms
          # request.xhr? ? false : ( RedmineCms.default_layout|| "base")
          use_layout_without_cms
        end

        def render_error_with_cms(arg)
          arg = {:message => arg} unless arg.is_a?(Hash)

          @message = arg[:message]
          @message = l(@message) if @message.is_a?(Symbol)
          @status = arg[:status] || 500

          respond_to do |format|
            format.html do
              if @page = RedmineCms.error_page
                render :text => @page.process(self), :layout => @page.layout ? false : use_layout, :status => @status
              else
                render :template => 'common/error', :layout => use_layout, :status => @status
              end
            end
            format.any { head @status }
          end
        end

        if Redmine::VERSION.to_s > '2.6'
          def set_localization_with_cms(user=User.current)
            if RedmineCms.settings[:use_localization]
              set_localization_without_cms
            else
              lang ||= Setting.default_language
              set_language_if_valid(lang)
            end
          end
        else
          def set_localization_with_cms
            if RedmineCms.settings[:use_localization]
              set_localization_without_cms
            else
              lang ||= Setting.default_language
              set_language_if_valid(lang)
            end
          end
        end

      end

    end
  end
end

unless ApplicationController.included_modules.include?(RedmineCMS::Patches::ApplicationControllerPatch)
  ApplicationController.send(:include, RedmineCMS::Patches::ApplicationControllerPatch)
end
