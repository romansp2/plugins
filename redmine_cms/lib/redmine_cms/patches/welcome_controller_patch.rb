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
  module Patches
    module WelcomeControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:include, CmsPagesHelper)

        base.class_eval do
          unloadable
          alias_method_chain :index, :cms
          before_filter :set_locale
          helper :cms_pages
        end
      end

      module InstanceMethods
        def index_with_cms
          @news = News.latest User.current
          @projects = Project.latest User.current
          if @page = CmsPage.includes([:attachments, :parts]).includes(:parts => :attachments).where(:id => RedmineCms.landing_page).first
            if @page.layout.blank?
              render :file => 'plugins/redmine_cms/app/views/cms_pages/show.html.erb'
            else
              render :text => @page.process(self), :layout => false
            end
          end

        end

      end

    end
  end
end

unless WelcomeController.included_modules.include?(RedmineCms::Patches::WelcomeControllerPatch)
  WelcomeController.send(:include, RedmineCms::Patches::WelcomeControllerPatch)
end
