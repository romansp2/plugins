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

class AttachmentDrop < RedmineCrm::BaseDrop
  delegate :id,
           :filename,
           :title,
           :description,
           :filesize,
           :content_type,
           :digest,
           :downloads,
           :created_on,
           :token,
           :visible?,
           :image?,
           :thumbnailable?,
           :is_text?,
           :readable?,
           :readable?,
           :to => :@_source

  def link
    link_to @_source.description.blank? ? @_source.filename : @_source.description, self.url
  end

  def url(options={})
    only_path = options.delete(:absolute).to_s != 'true'
    url_for({:controller => 'attachments', :action => 'download', :id => @_source, :filename => @_source.filename, :only_path => only_path}.merge(options))
  end

  def author
    @users ||= UsersDrop.new @_source.author
  end

  def read
    @content ||= if @_source.is_text? && @_source.filesize <= Setting.file_max_size_displayed.to_i.kilobyte
          File.new(@_source.diskfile, "rb").read
    end
    @content
  end

end

