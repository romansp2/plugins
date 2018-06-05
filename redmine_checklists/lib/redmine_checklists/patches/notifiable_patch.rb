# This file is a part of Redmine Checklists (redmine_checklists) plugin,
# issue checklists management plugin for Redmine
#
# Copyright (C) 2011-2016 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_checklists is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_checklists is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_checklists.  If not, see <http://www.gnu.org/licenses/>.


module RedmineChecklists
  module Patches
    module NotifiablePatch
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          unloadable
          class << self
              alias_method_chain :all, :checklists
          end
        end
      end

      module ClassMethods
        def all_with_checklists
          notifications = all_without_checklists
          last_issue_child_index = notifications.find_index(notifications.select{ |element| element.parent == 'issue_updated' }.last)
          notifications.insert(last_issue_child_index + 1, Redmine::Notifiable.new('checklist_updated', 'issue_updated'))
          notifications
        end
      end
    end
  end
end

unless Redmine::Notifiable.included_modules.include?(RedmineChecklists::Patches::NotifiablePatch)
  Redmine::Notifiable.send(:include, RedmineChecklists::Patches::NotifiablePatch)
end
