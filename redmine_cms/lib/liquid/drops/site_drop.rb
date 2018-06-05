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

class SiteDrop < Liquid::Drop
  def initialize
    @cms_site = CmsSite.instance
  end

  def assets
    return @attachments if @attachments
    @attachments = {}
    @cms_site.attachments.each{|f| @attachments[f.filename] = CmsAttachmentDrop.new f}
    @attachments
  end

  def variables
    return @variables if @variables
    @variables = {}
    CmsVariable.all.each{|v| @variables[v.name] = v.value}
    @variables
  end

  def allow_edit?
    RedmineCms.allow_edit?
  end

  def language
    CmsSite.language
  end

  def default_language
    Setting.default_language
  end

end
