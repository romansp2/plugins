# This file is a part of Redmine Finance (redmine_finance) plugin,
# simple accounting plugin for Redmine
#
# Copyright (C) 2011-2016 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_finance is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_finance is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_finance.  If not, see <http://www.gnu.org/licenses/>.

require_dependency 'queries_helper'

module RedmineFinance
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :column_value, :finance
        end
      end


      module InstanceMethods
        # include ContactsHelper

        def column_value_with_finance(column, list_object, value)
          if column.name == :income && list_object.is_a?(Operation)
            list_object.is_income? ? list_object.amount_to_s : ''
          elsif column.name == :expense && list_object.is_a?(Operation)
            list_object.is_income? ? '' : list_object.amount_to_s
          elsif column.name == :operation_date && list_object.is_a?(Operation)
            link_to format_time(value), operation_path(list_object)
          elsif value.is_a?(Operation)
            operation_tag(value, :no_contact => true, :plain => true, :size => 16)
          elsif value.is_a?(Account)
            account_tag(value, :no_contact => true, :plain => true, :size => 16)
          else
            column_value_without_finance(column, list_object, value)
          end
        end

      end

    end
  end
end

unless QueriesHelper.included_modules.include?(RedmineFinance::Patches::QueriesHelperPatch)
  QueriesHelper.send(:include, RedmineFinance::Patches::QueriesHelperPatch)
end
