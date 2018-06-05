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
  module Hooks
    class ControllerIssuesHook < Redmine::Hook::ViewListener
      def controller_issues_edit_after_save(context = {})
        if RedmineChecklists.settings[:save_log]
          old_checklists = context[:issue].old_checklists
          new_checklists = context[:issue].checklists.to_json
          journal = context[:journal]
          details = JournalChecklistHistory.new(old_checklists, new_checklists).journal_details
          if JournalChecklistHistory.can_fixup?(details)
            JournalChecklistHistory.fixup(details)
          elsif details.old_value != details.value
            journal.details << details
            journal.save
          else
            journal.save
          end
        end

        if (Setting.issue_done_ratio == "issue_field") && RedmineChecklists.settings[:issue_done_ratio]
          Checklist.recalc_issue_done_ratio(context[:issue].id)
        end
      end
    end
  end
end
