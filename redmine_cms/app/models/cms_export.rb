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

class CmsExport
  attr_accessor :attachment_content
  attr_reader   :errors

  def initialize(export_object)
    @export_object = export_object
    @errors = ActiveModel::Errors.new(self)
  end

  def configure(options = {})
    return unless options
    options.slice(:attachment_content).each { |opt, val| send("#{opt}=", val) }
  end

  def id
    @export_object.id
  end

  def object_type
    @export_object.class.name.underscore
  end

  def export
    @export_yaml ||= export_to_yaml
  end

  def export_website
    content = { :layouts => [], :pages => [], :snippets => [], :assets => [], :global_variables => [] }
    CmsLayout.find_each do |layout|
      @export_object = layout
      content[:layouts] << export_object_to_yaml(true)
    end
    CmsPage.order(:lft).each do |page|
      @export_object = page
      content[:pages] << export_page_to_yaml(true)
    end
    CmsSnippet.find_each do |snippet|
      @export_object = snippet
      content[:snippets] << export_object_to_yaml(true)
    end
    CmsSite.instance.attachments.find_each do |attachment|
      content[:assets] << attachment.attributes.slice('container_type', 'filename', 'content_type', 'description').
                                                merge(file_data(attachment))
    end
    CmsVariable.all.each do |variable|
      @export_object = variable
      content[:global_variables] << export_variable_to_yaml(true)
    end
    content.to_yaml
  end

  private

  def export_to_yaml
    case @export_object.class.name
    when 'CmsPage'
      return export_page_to_yaml
    when 'CmsLayout'
      return export_object_to_yaml
    when 'CmsSnippet'
      return export_object_to_yaml
    end
  end

  def export_page_to_yaml(original = false)
    attrs = @export_object.attributes.except!('id', 'created_at', 'updated_at', 'version', 'parent_id', 'project_id', 'layout_id', 'lft', 'rgt')
    attrs.merge!(page_parent)
    attrs.merge!(page_layout)
    attrs.merge!(page_parts)
    attrs.merge!(page_fields)
    attrs.merge!(page_tags)
    attrs.merge!(shared_attributes)
    original ? attrs : attrs.to_yaml
  end

  def export_object_to_yaml(original = false)
    attrs = @export_object.attributes.except!('id', 'created_at', 'updated_at', 'version')
    attrs.merge!(shared_attributes)
    original ? attrs : attrs.to_yaml
  end

  def export_variable_to_yaml(original = false)
    attrs = @export_object.attributes
    original ? attrs : attrs.to_yaml
  end

  def page_parent
    { 'parent_name' => @export_object.parent.try(:name) }
  end

  def page_layout
    { 'layout_name' => @export_object.layout.try(:name) }
  end

  def page_parts
    return {} if @export_object.parts.empty?
    parts_attibutes = @export_object.parts.map do |part|
                        part.attributes.except!('id', 'created_at', 'updated_at', 'version', 'page_id').
                             merge('page_name' => @export_object.name)
                      end
    { 'parts' => parts_attibutes }
  end

  def page_fields
    return {} if @export_object.fields.empty?
    fields_attibutes = @export_object.fields.map do |field|
                         field.attributes.except!('id', 'created_at', 'updated_at', 'page_id').
                               merge('page_name' => @export_object.name)
                       end
    { 'fields' => fields_attibutes }
  end

  def page_tags
    { 'tags' => @export_object.tag_list.join(',') }
  end

  def shared_attributes
    shared_attributes = {}
    shared_attributes.merge(attachments_to_yaml)
  end

  def attachments_to_yaml
    return {} if @export_object.attachments.empty?
    attachments_attibutes = @export_object.attachments.reverse.map do |attachment|
                              attachment.attributes.slice('container_type', 'filename', 'content_type', 'description').
                                         merge('page_name' => @export_object.name).
                                         merge(file_data(attachment))
                            end
    { 'attachments' => attachments_attibutes }
  end

  def file_data(file)
    @attachment_content.to_i > 0 ? file_content(file) : file_url(file)
  end

  def file_content(file)
    { 'file_content' => File.open(file.diskfile, 'rb') { |f| Base64.encode64(f.read) } }
  end

  def file_url(file)
    { 'file_url' => Rails.application.routes.url_helpers.
                          download_named_attachment_url(file,
                                                        :filename => file.filename,
                                                        :host => Setting.host_name,
                                                        :protocol => Setting.protocol) }
  end
end
