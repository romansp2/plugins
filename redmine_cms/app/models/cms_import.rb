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

class CmsImport
  require 'open-uri'
  attr_accessor :file, :rewrite, :author
  attr_reader :errors

  def initialize(import_object)
    @import_object = import_object
    @errors = ActiveModel::Errors.new(self)
  end

  def configure(options = {})
    return unless options
    options.slice(:file, :rewrite).each { |opt, val| send("#{opt}=", val) }
  end

  def object_type
    @import_object.class.name.underscore
  end

  def import
    data = YAML.load_file(RUBY_VERSION >= '1.9.3' ? file.tempfile : file.path)
    import_object(data)
  end

  def import_website(file_path = nil)
    file_path = RUBY_VERSION >= '1.9.3' ? file.tempfile : file.path unless file_path
    data = YAML.load_file(file_path)
    CmsPage.transaction do
      data[:layouts].each { |layout| import_layout(layout) }
      data[:pages].each { |page| import_page(page) }
      data[:snippets].each { |snippet| import_snippet(snippet) }
      data[:assets].each { |asset| import_assets(asset) }
      data[:global_variables].each { |global_variable| import_global_variable(global_variable) }
      CmsPage.rebuild_tree!
    end
  end

  private

  def import_object(data)
    case @import_object.class.name
    when 'CmsPage'
      return import_page(data)
    when 'CmsLayout'
      return import_layout(data)
    when 'CmsSnippet'
      return import_snippet(data)
    end
  end

  def import_page(data)
    page = CmsPage.where(:name => data['name']).first || CmsPage.new
    page.errors.add(:base, I18n.t(:label_crm_import_page_exist)) if rewrite.to_i.zero? && page.persisted?
    return page unless page.errors.empty?
    CmsPage.transaction do
      page.assign_attributes(data.except('fields', 'attachments', 'parts', 'parent_name', 'layout_name', 'tags', 'lft', 'rgt'))
      page.author = @author
      page.tag_list = data['tags'].split(',')
      page.parent = CmsPage.where(:name => data['parent_name']).first if data['parent_name'].present?
      page.layout = CmsLayout.where(:name => data['layout_name']).first if data['layout_name'].present?
      return page unless page.save
      import_parts(page, data['parts'])
      import_fields(page, data['fields'])
      import_attachments(page, data['attachments'])
    end
    page
  end

  def import_layout(data)
    layout = CmsLayout.where(:name => data['name']).first || CmsLayout.new
    return layout.errors.add(:base, I18n.t(:label_crm_import_layout_exist)) if rewrite.to_i.zero? && layout.persisted?
    CmsLayout.transaction do
      layout.assign_attributes(data.except('attachments'))
      return layout unless layout.save
      import_attachments(layout, data['attachments'])
    end
    layout
  end

  def import_snippet(data)
    snippet = CmsSnippet.where(:name => data['name']).first || CmsSnippet.new
    return snippet.errors.add(:base, I18n.t(:label_crm_import_snippet_exist)) if rewrite.to_i.zero? && snippet.persisted?
    CmsSnippet.transaction do
      snippet.assign_attributes(data.except('attachments'))
      return snippet unless snippet.save
      import_attachments(snippet, data['attachments'])
    end
    snippet
  end

  def import_assets(data)
    asset = CmsSite.instance.attachments.where(:filename => data['filename']).first || CmsSite.instance.attachments.new
    return asset.errors.add(:base, I18n.t(:label_crm_import_asset_exist)) if asset.persisted?
    Attachment.transaction do
      asset = create_from_content(data) if data['file_content'].present?
      asset = create_from_url(data) if data['file_url'].present?
      asset.update_attributes(:container_id => 1, :container_type => CmsSite.name) if asset
    end
    asset
  end

  def import_global_variable(data)
    variable = CmsVariable[data[:name]] || CmsVariable.new
    return variable.errors.add(:base, I18n.t(:label_crm_import_variable_exist)) if rewrite.to_i.zero? && variable.persisted?
    variable.name = data[:name]
    variable.value = data[:value]
    variable.save
    variable
  end

  def import_parts(page, parts)
    return if parts.nil? || parts.empty?
    parts.each do |part|
      existed_part = page.parts.where(:name => part['name']).first
      existed_part ? existed_part.update_attributes(part.except('page_name')) : page.parts.create!(part.except('page_name'))
    end
  end

  def import_fields(page, fields)
    return if fields.nil? || fields.empty?
    fields.each do |field|
      existed_field = page.fields.where(:name => field['name']).first
      existed_field ? existed_field.update_attributes(field.except('page_name')) : page.fields.create!(field.except('page_name'))
    end
  end

  def import_attachments(object, attachments)
    return if attachments.nil? || attachments.empty?
    attachments.each do |attachment|
      next if object.attachments.where(:filename => attachment['filename']).first
      object.attachments << create_from_content(attachment) if attachment['file_content'].present?
      object.attachments << create_from_url(attachment) if attachment['file_url'].present?
    end
  end

  def create_from_content(attachment)
    temp_file = Tempfile.new(attachment['filename'])
    temp_file.binmode
    temp_file.write(Base64.decode64(attachment['file_content']))
    temp_file.rewind
    Attachment.new(:file => temp_file.read,
                   :author => @author,
                   :filename => attachment['filename'],
                   :content_type => attachment['content_type'],
                   :description => attachment['description'])
  end

  def create_from_url(attachment)
    Attachment.new(:file => open(attachment['file_url']),
                   :author => @author,
                   :filename => attachment['filename'],
                   :content_type => attachment['content_type'],
                   :description => attachment['description'])
  end
end
