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

class CmsVariable
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include Redmine::SafeAttributes

  attr_accessor :name, :value

  validates_presence_of :name, :value
  validates_length_of :name, :maximum => 30
  validates_format_of :name, :with => /\A(?!\d+$)[a-z0-9\-_]*\z/

  validate :validate_cms_variable

  def self.all
    cms_variables = Setting.plugin_redmine_cms["cms_variables"].is_a?(Hash) ? Setting.plugin_redmine_cms["cms_variables"] : {}
    cms_variables.map{|k, v| CmsVariable.new(:name => k, :value => v) }
  end

  def self.[](key)
    all.detect{|l| l.name.to_s.downcase.strip == key.to_s.downcase.strip}
  end

  def self.find_by_action(ctrl, actn)
    all.select{|l| l.controller == ctrl.to_s.downcase.strip}.detect{|l| l.action == actn.to_s.downcase.strip || l.action.blank? }
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
    cms_variables = Setting.plugin_redmine_cms["cms_variables"].is_a?(Hash) ? Setting.plugin_redmine_cms["cms_variables"] : {}
    cms_variables.merge!(name => value)
    Setting.plugin_redmine_cms = Setting.plugin_redmine_cms.merge({"cms_variables" => cms_variables})
  end

  def destroy
    cms_variables = Setting.plugin_redmine_cms["cms_variables"].is_a?(Hash) ? Setting.plugin_redmine_cms["cms_variables"] : {}
    cms_variables.delete(name)
    Setting.plugin_redmine_cms = Setting.plugin_redmine_cms.merge({"cms_variables" => cms_variables})
    true
  end

  def to_param
    name
  end

  def persisted?
    false
  end

  def attributes
    { :name => name, :value => value }
  end

  private

  def validate_cms_variable
  end

end
