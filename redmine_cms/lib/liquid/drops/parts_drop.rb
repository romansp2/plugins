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

class PartsDrop < RedmineCrm::BaseDrop

  def before_method(name)
    part = @_source.detect{|p| p.name == name}
    return false unless part
    PartDrop.new part
  end

  def all
    @all ||= @_source.map do |part|
      PartDrop.new part
    end
  end

  def active
    @active ||= @_source.active.map do |part|
      PartDrop.new part
    end
  end

  def each(&block)
    all.each(&block)
  end

end


class PartDrop < RedmineCrm::BaseDrop

  delegate :name, :description, :content, :filter_id, :active?, :digest, :to => :@_source

  def url(options={})
    only_path = options.delete(:absolute).to_s != 'true'
    url_for({:controller => 'cms_parts', :action => "show", :name => @_source.name, :page_id => @_source.page.id, :only_path => only_path}.merge(options)) if @_source.page.id
  end

  def page
    @_source ||= PageDrop.new(@_source.page) if @_source.page
  end

end
