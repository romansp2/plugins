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

module RedmineCrm
  class BaseDrop < ::Liquid::Drop
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper
    include Rails.application.routes.url_helpers


    def initialize(source)
      @_source = source
    end

    def id
      (@_source.respond_to?(:id) ? @_source.id : nil) || 'new'
    end

    def url_options
      options = {:protocol => Setting.protocol}
      if Setting.host_name.to_s =~ /\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i
        host, port, prefix = $2, $4, $5
        options.merge!({
          :host => host, :port => port, :script_name => prefix
        })
      else
        options[:host] = Setting.host_name
      end
      options
    end

  end
end
