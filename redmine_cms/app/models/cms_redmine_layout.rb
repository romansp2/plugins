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

class CmsRedmineLayout
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include Redmine::SafeAttributes

  attr_accessor :redmine_action, :cms_layout_id

  validates_presence_of :redmine_action, :cms_layout_id
  validates_length_of :redmine_action, :maximum => 200
  validate :validate_redmine_layout

  def self.all
    redmine_layouts = Setting.plugin_redmine_cms["redmine_layouts"].is_a?(Hash) ? Setting.plugin_redmine_cms["redmine_layouts"] : {}
    redmine_layouts.map{|k, v| CmsRedmineLayout.new(:redmine_action => k, :cms_layout_id => v) }
  end

  def self.[](key)
    all.detect{|l| l.redmine_action.to_s.downcase.strip == key.to_s.downcase.strip}
  end

  def self.find_by_action(ctrl, actn)
    all.select{|l| l.controller == ctrl.to_s.downcase.strip}.detect{|l| l.action == actn.to_s.downcase.strip || l.action.blank? }
  end


  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def layout
    CmsLayout.find_by_id(cms_layout_id)
  end

  def controller
    redmine_action.to_s.downcase.gsub(' ', '').split('#')[0]
  end

  def action
    redmine_action.to_s.downcase.gsub(' ', '').split('#')[1]
  end


  def save
    if !valid?
      errors.messages.each{|k, msg| Rails.logger.info "attribute #{k} #{msg.first}('#{send(k)}')"}
      return false
    end
    redmine_layouts = Setting.plugin_redmine_cms["redmine_layouts"].is_a?(Hash) ? Setting.plugin_redmine_cms["redmine_layouts"] : {}
    redmine_layouts.merge!(redmine_action => cms_layout_id)
    Setting.plugin_redmine_cms = Setting.plugin_redmine_cms.merge({"redmine_layouts" => redmine_layouts})
  end

  def destroy
    redmine_layouts = Setting.plugin_redmine_cms["redmine_layouts"].is_a?(Hash) ? Setting.plugin_redmine_cms["redmine_layouts"] : {}
    redmine_layouts.delete(redmine_action)
    Setting.plugin_redmine_cms = Setting.plugin_redmine_cms.merge({"redmine_layouts" => redmine_layouts})
    true
  end

  def to_param
    redmine_action
  end

  def persisted?
    false
  end

  private

  def validate_redmine_layout
    errors.add :cms_layout, 'Invalid layout' unless CmsLayout.find_by_id(cms_layout_id).present?
  end

end
