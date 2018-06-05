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

class CmsAttachmentDrop < AttachmentDrop
  def thumbnail_url(options={})
    only_path = options.delete(:absolute).to_s != 'true'
    size = options.delete(:size) || '100'
    url_for({:controller => 'cms_assets', :action => 'thumbnail', :id => @_source, :filename => @_source.filename, :size => size, :only_path => only_path}.merge(options))
  end

  def asset_url(options={})
    only_path = options.delete(:absolute).to_s != 'true'
    url_for({:controller => 'cms_assets', :action => 'download', :id => @_source, :filename => @_source.filename, :only_path => only_path}.merge(options))
  end

end

