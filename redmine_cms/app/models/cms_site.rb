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

require 'singleton'

class CmsSite
  unloadable
  include RedmineCms::ActsAsAttachableCms
  include Singleton
  include Redmine::I18n

  @@language = Setting.default_language || 'en'

  acts_as_attachable_cms

  class << self
    def locales
      @locales ||= valid_languages.map{|l| l.to_s.downcase}
    end

    def language
      if RedmineCms.use_localization?
        @@language || Setting.default_language || 'en'
      else
        Setting.default_language || 'en'
      end
    end

    def language=(lang)
      @@language = CmsSite.locales.include?(lang) && lang
    end

  end

  def attachments
    Attachment.where(:container_type => self.class.name)
  end

end
