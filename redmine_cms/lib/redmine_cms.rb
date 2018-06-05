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

require "liquid/drops/base_drop.rb"
require "liquid/drops/attachment_drop.rb"
require "liquid/drops/cms_attachment_drop.rb"
require "liquid/drops/menus_drop.rb"
require "liquid/drops/pages_drop.rb"
require "liquid/drops/parts_drop.rb"
require "liquid/drops/request_drop.rb"
require "liquid/drops/site_drop.rb"
require "liquid/drops/issues_drop.rb"
require "liquid/drops/news_drop.rb"
require "liquid/drops/projects_drop.rb"
require "liquid/drops/users_drop.rb"

Dir[File.dirname(__FILE__) + '/liquid/tags/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/liquid/filters/*.rb'].each { |f| require f }

require 'redmine_cms/helpers/cms_helper'

require 'redmine_cms/patches/projects_helper_patch'
require 'redmine_cms/patches/menu_manager_patch'
require 'redmine_cms/patches/attachments_controller_patch'
require 'redmine_cms/patches/application_controller_patch'
require 'redmine_cms/patches/projects_controller_patch'
require 'redmine_cms/patches/welcome_controller_patch'
require 'redmine_cms/patches/attachment_patch'

require 'redmine_cms/hooks/views_layouts_hook'
require 'redmine_cms/wiki_macros/cms_wiki_macros'

require 'acts_as_versionable_cms'
require 'redmine_cms/acts_as_attachable_cms'
require 'redmine_cms/textile_formater'
require 'redmine_cms/html_compressor'

require 'redmine_cms/text_filter'
require 'redmine_cms/textile_filter'
require 'redmine_cms/sass_filter'
require 'redmine_cms/scss_filter'
require 'redmine_cms/javascript_filter'

require 'redmine_cms/page_finder'
require 'redmine_cms/page_nested_set'


module RedmineCms

  STATUS_ACTIVE = 1
  STATUS_LOCKED = 0


  class << self
    def settings() Setting[:plugin_redmine_cms].is_a?(Hash) ? Setting[:plugin_redmine_cms] : {} end

    def cache_expires_in
      expires_in = self.settings["cache_expires_in"].to_i
      expires_in > 0 ? expires_in : 15
    end

    def use_localization?
      self.settings["use_localization"].to_i > 0
    end

    def default_layout
      self.settings["default_layout"] && CmsLayout.find_by_id(self.settings["default_layout"])
    end

    def error_page
      self.settings["error_page"] && CmsPage.find(self.settings["error_page"])
    end

    def allow_edit?(user=User.current)
      user_ids = [user.id] + user.groups.map(&:id)
      return true if user.admin?
      return true if user_ids.include?(self.settings["edit_permissions"].to_i) && user.logged?
      false
    end

    def landing_page
      return settings["landing_page"].to_i if settings["landing_page"].to_i  > 0
    end

    def redirects
      settings["redirects"].is_a?(Hash) ? settings["redirects"] : settings["redirects"] = {}
    end

    def save_settings
      # cms_settings = self.settings
      # cms_settings = {} unless cms_settings.is_a?(Hash)
      # cms_settings.merge!(index => value)
      Setting.plugin_redmine_cms = self.settings
    end

    def set_project_settings(name, project_id, v)
      settings[:project] = {project_id => {}} unless settings[:project]
      settings[:project][project_id] = {name => ''} unless settings[:project][project_id]
      settings[:project][project_id][name] = v if settings[:project][project_id]
      Setting[:plugin_redmine_cms] = settings
    end

    def get_project_settings(name, project_id)
      settings[:project][project_id][name] if settings[:project] && settings[:project][project_id]
    end

    def default_page_fields
      settings["default_fields"].to_s.split(',').map(&:strip)
    end

    def view_layouts_base_html_head_hook
      settings["view_layouts_base_html_head_hook"]
    end

    def view_layouts_base_sidebar_hook
      settings["view_layouts_base_sidebar_hook"]
    end

    def view_layouts_base_body_bottom_hook
      settings["view_layouts_base_body_bottom_hook"]
    end


  end

  module Layout

    LIST = %w(Default Redmine CMS None)

    class << self

      def layout_file_name(name)
        if name.blank?
          'base'
        else
          'cms_custom'
        end
      end

      def for_select(options={})
        LIST.reject{ |l| l == 'Default' && options[:for_settigns] }.map{ |l| [l, l] }
      end
    end

  end


end
