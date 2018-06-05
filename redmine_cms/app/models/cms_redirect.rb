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

class CmsRedirect
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include Redmine::SafeAttributes

  attr_accessor :source_path, :destination_path

  validates_presence_of :source_path, :destination_path
  validates_format_of :source_path, :with => /\A(?!\d+$)\/[a-z0-9\-_\/]*\z/i, :message => "Invalide format"
  validates_length_of :source_path, :destination_path, :maximum => 200
  validate :validate_redirect

  def self.all
    RedmineCms.redirects.map{|k, v| CmsRedirect.new(:source_path => k, :destination_path => v) }
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    if !valid?
      errors.messages.each{|k, msg| Rails.logger.info "attribute #{k} #{msg.first}('#{send(k)}')"}
      return false
    end
    redirects = Setting.plugin_redmine_cms["redirects"].is_a?(Hash) ? Setting.plugin_redmine_cms["redirects"] : {}
    redirects.merge!(source_path => destination_path)
    Setting.plugin_redmine_cms = Setting.plugin_redmine_cms.merge({"redirects" => redirects})
  end

  def destroy
    redirects = Setting.plugin_redmine_cms["redirects"].is_a?(Hash) ? Setting.plugin_redmine_cms["redirects"] : {}
    redirects.delete(source_path)
    Setting.plugin_redmine_cms = Setting.plugin_redmine_cms.merge({"redirects" => redirects})
    true
  end

  def to_param
    if source_path == "/"
      "_"
    else
      source_path.parameterize
    end
  end

  def persisted?
    false
  end

  private

  def validate_redirect
    if source_path.to_s.start_with?("/admin", "/settings", "/users", "/groups", "/plugins", "/cms")
      errors.add :source_path, 'Invalid source path'
    end
    begin
      Rails.application.routes.recognize_path(source_path.to_s)
    rescue => e
      errors.add :source_path, e.message
    end
  end

end
