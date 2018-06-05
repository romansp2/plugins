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

class CmsPart < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes
  include RedmineCms::Filterable

  belongs_to :page, :class_name => 'CmsPage', :foreign_key => 'page_id'

  acts_as_attachable_cms
  acts_as_versionable_cms
  acts_as_list :scope => 'page_id = \'#{page_id}\''

  scope :active, lambda{where(:status_id => RedmineCms::STATUS_ACTIVE)}

  liquid_methods :name, :attachments, :description

  after_commit :touch_page

  validates_presence_of :name, :content, :page
  validates_format_of :name, :with => /\A(?!\d+$)[a-z0-9\-_]*\z/

 [:content, :header, :footer, :sidebar].each do |name, params|
    src = <<-END_SRC
    def is_#{name}_type?
      self.name.strip.downcase == "#{name.to_s}"
    end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end

  attr_protected :id
  safe_attributes 'name',
    'description',
    'filer_id',
    'status_id',
    'page_id',
    'is_cached',
    'content'

  def copy_from(arg)
    part = arg.is_a?(CmsPart) ? arg : CmsPart.find_by_id(arg)
    self.attributes = part.attributes.dup.except("id", "created_at", "updated_at") if part
    self
  end

  def active?
    self.status_id == RedmineCms::STATUS_ACTIVE
  end

  def to_s
    ERB::Util.html_escape(name)
  end

  def digest
    @generated_digest ||= digest!
  end

  def digest!
    Digest::MD5.hexdigest(self.content)
  end

  def title
    self.description.to_s.strip.blank? ? self.name : "#{self.description} (#{self.name})"
  end

  def self.find_part(*args)
    if args.first && args.first.is_a?(String) && !args.first.match(/^\d*$/)
      find_by_name(*args)
    else
      find(*args)
    end
  end

private
  def touch_page
    if page
      page.touch
      page.expire_cache
    end
  end

end
