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

class CmsPage < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes
  include RedmineCms::Filterable
  include RedmineCms::PageNestedSet

  attr_accessor :page_params

  belongs_to :layout, :class_name => 'CmsLayout', :foreign_key => 'layout_id'
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  has_many :parts, :class_name => 'CmsPart', :foreign_key => 'page_id', :dependent => :destroy

  if ActiveRecord::VERSION::MAJOR >= 4
    has_many :fields, lambda {order(:name)}, :class_name => 'CmsPageField', :foreign_key => 'page_id', :dependent => :destroy
  else
    has_many :fields, :class_name => 'CmsPageField', :foreign_key => 'page_id', :dependent => :destroy, :order => "#{CmsPageField.table_name}.name"
  end

  acts_as_attachable_cms
  acts_as_versionable_cms
  rcrm_acts_as_taggable

  scope :active, lambda {where(:status_id => RedmineCms::STATUS_ACTIVE)}
  scope :status, lambda {|arg| where(arg.blank? ? nil : {:status_id => arg.to_i}) }
  scope :visible, lambda {where(CmsPage.visible_condition)}
  scope :like, lambda {|arg|
    if arg.blank?
      where(nil)
    else
      pattern = "%#{arg.to_s.strip}%"
      where("(LOWER(#{CmsPage.table_name}.content) LIKE LOWER(:p)) OR (LOWER(#{CmsPage.table_name}.name) LIKE LOWER(:p)) OR (LOWER(#{CmsPage.table_name}.title) LIKE LOWER(:p))", :p => pattern)
    end
  }

  validates_presence_of :name, :slug
  validates_uniqueness_of :name
  validates_uniqueness_of :slug, :scope => :parent_id
  validates_length_of :name, :maximum => 255
  validates_length_of :title, :maximum => 255
  validate :validate_page
  validates_format_of :name, :slug, :with => /\A(?!\d+$)[a-z0-9\-_]*\z/i

  accepts_nested_attributes_for :fields, :allow_destroy => true

  attr_accessor :listener, :context

  [:content, :header, :sidebar].each do |name, params|
    src = <<-END_SRC
    def #{name}_parts
      pages_parts.includes(:part).where(:parts => {:part_type => "#{name.to_s}"})
    end

    END_SRC
    class_eval src, __FILE__, __LINE__
  end
  attr_protected :id
  safe_attributes 'name',
    'slug',
    'title',
    'visibility',
    'filter_id',
    'is_cached',
    'content',
    'page_date',
    'layout_id',
    'parent_id',
    'tag_list',
    'fields_attributes'

  def self.visible_condition(user=User.current)
    user_ids = [user.id] + user.groups.map(&:id)
    cond = "(1=1) "
    cond << " AND (#{table_name}.status_id = #{RedmineCms::STATUS_ACTIVE})" unless RedmineCms.allow_edit?(user)
    cond << " AND ((#{table_name}.visibility = 'public')"
    cond << "      OR (#{table_name}.visibility = 'logged')" if user.logged?
    cond << "      OR (#{table_name}.visibility IN (#{user_ids.join(',')})))"
  end

  def visible?(user=User.current)
    if active?
      return true if visibility == 'public'
      return true if visibility == 'logged' && user.logged?
      user_ids = [user.id] + user.groups.map(&:id)
      return true if user_ids.include?(visibility.to_i) && user.logged?
    end
    RedmineCms.allow_edit?(user)
  end

  def active?
    self.status_id == RedmineCms::STATUS_ACTIVE
  end

  def to_param
    name.parameterize
  end

  def reload(*args)
    @valid_parents = nil
    super
  end

  def to_s
    name
  end

  def page_fields
    @page_fields ||= fields.inject({}) { |mem, var| mem[var.name] = var.content; mem }
  end

  def valid_parents
    @valid_parents ||= CmsPage.all - self_and_descendants
  end

  def self.tags_cloud(options={})

    scope = RedmineCrm::Tag.where({})
    join = []
    join << "JOIN #{RedmineCrm::Tagging.table_name} ON #{RedmineCrm::Tagging.table_name}.tag_id = #{RedmineCrm::Tag.table_name}.id "
    join << "JOIN #{CmsPage.table_name} ON #{CmsPage.table_name}.id = #{RedmineCrm::Tagging.table_name}.taggable_id AND #{RedmineCrm::Tagging.table_name}.taggable_type =  '#{CmsPage.name}' "

    group_fields = ""
    group_fields << ", #{RedmineCrm::Tag.table_name}.created_on" if RedmineCrm::Tag.respond_to?(:created_on)
    group_fields << ", #{RedmineCrm::Tag.table_name}.updated_on" if RedmineCrm::Tag.respond_to?(:updated_on)

    scope = scope.joins(join.join(' '))
    scope = scope.select("#{RedmineCrm::Tag.table_name}.*, COUNT(DISTINCT #{RedmineCrm::Tagging.table_name}.taggable_id) AS count")
    scope = scope.group("#{RedmineCrm::Tag.table_name}.id, #{RedmineCrm::Tag.table_name}.name #{group_fields} HAVING COUNT(*) > 0")
    scope = scope.order("#{RedmineCrm::Tag.table_name}.name")
    scope = scope.limit(options[:limit]) if options[:limit]
    scope
  end


  # Yields the given block for each project with its level in the tree
  def self.page_tree(pages, &block)
    ancestors = []
    pages.sort_by(&:lft).each do |page|
      while (ancestors.any? && !page.is_descendant_of?(ancestors.last))
        ancestors.pop
      end
      yield page, ancestors.size
      ancestors << page
    end
  end

  def copy_from(arg)
    page = arg.is_a?(CmsPage) ? arg : CmsPage.find_by_name(arg)
    self.attributes = page.attributes.dup.except("id", "created_at", "updated_at")
    self.tags << page.tags
    self.fields = page.fields.map{|f| CmsPageField.new f.attributes.dup.except("id", "page_id")}
    self.name = self.name.to_s + "_copy"
    self
  end

  def process(listener, page_params={})
    @page_params = page_params.is_a?(Hash) ? page_params : {}
    @listener = listener
    set_response_headers(@listener.response)
    @listener.response.status = response_code
    @listener.response.body = render
  end

  def headers
    # Return a blank hash that child classes can override or merge
    { }
  end

  def set_response_headers(response)
    set_content_type(response)
    headers.each { |k,v| response.headers[k] = v }
  end
  private :set_response_headers

  def set_content_type(response)
    if layout
      content_type = layout.content_type.to_s.strip
      if content_type.present?
        response.headers['Content-Type'] = content_type
      end
    end
  end
  private :set_content_type

  def response_code
    200
  end

  def render
    if layout
      render_object(layout)
    else
      render_page
    end
  end

  def render_page
    if self.is_cached?
      Rails.cache.fetch(self, :expires_in => RedmineCms.cache_expires_in.minutes) { render_page_with_content_parts(self) }
    else
      render_page_with_content_parts(self)
    end
  end

  def render_part(part)
    if part.respond_to?(:is_cached) && part.is_cached?
      Rails.cache.fetch(part, :expires_in => RedmineCms.cache_expires_in.minutes) {render_object(part)}
    else
      render_object(part)
    end
  end

  def digest
    @generated_digest ||= digest!
  end

  def expire_cache
    if Rails.cache.respond_to?(:delete_matched)
      Rails.cache.delete_matched(self.cache_key)
    else
      Rails.cache.delete(self)
    end
    self.parts.each do |part|
      Rails.cache.delete(part)
    end
  end

  def digest!
    # Digest::MD5.hexdigest(self.render)
    self.updated_at.to_formatted_s(:number)
  end

  def initialize_context(page_listener)
    assigns = {}
    assigns['users'] = UsersDrop.new(User.sorted)
    assigns['current_user'] = UserDrop.new(User.current)
    assigns['projects'] = ProjectsDrop.new(Project.visible.order(:name))
    assigns['newss'] = NewssDrop.new(News.visible.order("#{News.table_name}.created_on"))
    assigns['page'] = PageDrop.new(self)
    assigns['pages'] = PagesDrop.new(CmsPage.visible)
    assigns['current_page'] = page_listener.request.params[:page] || 1 if page_listener
    assigns['params'] = page_listener.request.params if page_listener
    assigns['flash'] = page_listener.flash.to_hash if page_listener
    assigns['action_variables'] = page_listener.instance_variable_names.inject({}){|memo, value| memo.merge(value => page_listener.instance_variable_get(value))} if page_listener
    assigns['now'] = Time.now
    assigns['today'] = Date.today
    assigns['site'] = SiteDrop.new
    assigns['page_params'] = @page_params

    registers = {}
    registers[:page] = self
    registers[:listener] = page_listener
    ::Liquid::Context.new({}, assigns, registers)
  end

  def self.find_by_path(path)
    if path == '/' && RedmineCms.landing_page
      CmsPage.find(RedmineCms.landing_page)
    else
      RedmineCms::Pages::Finder.find(path)
    end
  end

  def path
    @path ||= self_and_ancestors.pluck(:slug).join('/')
  end
  alias_method :url, :path

  def in_locale(page_locale = CmsSite.language)
    return self if locale == page_locale
    return false unless CmsSite.locales.include?(page_locale)
    return CmsPage.find_by_path(page_locale) if id == RedmineCms.landing_page

    default_path = path
    if path =~ /^\/?(#{CmsSite.locales.join('|')})+(\/|$)/
      self_locale = $1
      default_path = path.gsub($1 + $2, '')
      default_path = '/' if default_path.blank?
    end

    if page_locale == Setting.default_language
      localized_path = default_path
    else
      localized_path = [page_locale, default_path].join('/')
    end

    CmsPage.find_by_path(localized_path)
  end

  def locale
    path.to_s[/^\/?(#{CmsSite.locales.join('|')})+(\/|$)/, 1] || Setting.default_language.to_s
  end

  protected

  def validate_page
    if parent_id && parent_id_changed?
      errors.add(:parent_id, :invalid) unless valid_parents.include?(parent)
    end
  end


  private

  def render_page_with_content_parts(page)
    s = render_part(page)
    page.parts.where(:name => 'content').active.order(:position).each do |page_part|
      s << render_part(page_part)
    end
    s
  end

  def render_liquid(cms_object)
    @context ||= initialize_context(@listener)
    begin
      old_object = @context.registers[:cms_object]
      @context.registers[:cms_object] = cms_object
      ::Liquid::Template.parse(cms_object.content).render(@context).html_safe
    rescue => e
      e.message
    ensure
      @context.registers[:cms_object] = old_object
    end
  end

  def render_object(cms_object)
    text = render_liquid(cms_object)
    text = cms_object.filter.filter(text, cms_object) if cms_object.respond_to? :filter_id
    text = RedmineCms::HtmlCompressor::Compressor.new.compress(text) if false
    text.html_safe
  end


end
