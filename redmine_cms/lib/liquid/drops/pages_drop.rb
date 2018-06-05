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

class PagesDrop < RedmineCrm::BaseDrop

  def all
    @all ||= @_source.map do |page|
      PageDrop.new page
    end
  end

  def active
    @active ||= @_source.active.map do |page|
      PageDrop.new page
    end
  end

  def visible
    @visible ||= @_source.visible.map do |page|
      PageDrop.new page
    end
  end

  def each(&block)
    all.each(&block)
  end

  def before_method(name)
    page = @_source.detect{|p| p.name == name}
    return false unless page
    PageDrop.new page
  end

end


class PageDrop < RedmineCrm::BaseDrop

  delegate :id,
           :name,
           :slug,
           :path,
           :title,
           :description,
           :content,
           :content_type,
           :page_date,
           :tag_list,
           :created_at,
           :updated_at,
           :digest,
           :locale,
           :status_id,
           :visible?,
           :active?,
           :version, :to => :@_source

  def url(options={})
    only_path = options.delete(:absolute).to_s != 'true'
    localized = options.delete(:localized).to_s == 'true'
    page_locale = options[:locale]
    page_path = @_source.in_locale(page_locale || CmsSite.language).try(:path) if RedmineCms.use_localization? && localized
    page_path ||= @_source.path
    return if page_path.blank?
    url_for({:controller => 'cms_pages', :action => "show", :path => page_path, :only_path => only_path}.merge(options)) if page_path
  end

  def children
    @children ||= PagesDrop.new @_source.children #.map{|p| PageDrop.new(p)}
  end

  def ancestors
    @ancestors ||= PagesDrop.new @_source.ancestors #.map{|p| PageDrop.new(p)}
  end

  def layout
    @_source.layout && @_source.layout.name
  end

  def leaves
    @leaves ||= PagesDrop.new @_source.leaves #.map{|p| PageDrop.new(p)}
  end

  def descendants
    @descendants ||= PagesDrop.new @_source.descendants #.map{|p| PageDrop.new(p)}
  end

  def parts
    @parts ||= PartsDrop.new @_source.parts
  end

  def fields
    @_source.page_fields
  end

  def parent
    @parent ||= PageDrop.new(@_source.parent) if @_source.parent
  end

  def date
    @_source.page_date || @_source.created_at
  end

  def author
    @author ||= UserDrop.new(@_source.author) if @_source.author
  end

  def in_locale(page_locale = CmsSite.language)
    localized_page = @_source.in_locale(page_locale)
    PageDrop.new localized_page if localized_page
  end

  def attachments
    return @attachments if @attachments
    @attachments = {}
    @_source.attachments.each{|f| @attachments[f.filename] = CmsAttachmentDrop.new f}
    @attachments
  end

  def dump?
    @_source.name.blank?
  end

end
