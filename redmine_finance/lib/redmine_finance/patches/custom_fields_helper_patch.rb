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

require_dependency 'custom_fields_helper'

module RedmineFinance
  module Patches

    module CustomFieldsHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          alias_method_chain :custom_fields_tabs, :finance_tab
        end
      end

      module InstanceMethods
        # Adds a rates tab to the user administration page
        def custom_fields_tabs_with_finance_tab
          tabs = custom_fields_tabs_without_finance_tab
          tabs << {:name => 'OperationCustomField', :partial => 'custom_fields/index', :label => :label_operation_plural}
          tabs << {:name => 'AccountCustomField', :partial => 'custom_fields/index', :label => :label_account_plural}
          return tabs
        end
      end

    end

  end
end

if Redmine::VERSION.to_s > '2.5'
  CustomFieldsHelper::CUSTOM_FIELDS_TABS << {:name => 'OperationCustomField', :partial => 'custom_fields/index', :label => :label_operation_plural}
  CustomFieldsHelper::CUSTOM_FIELDS_TABS << {:name => 'AccountCustomField', :partial => 'custom_fields/index', :label => :label_account_plural}
else
  unless CustomFieldsHelper.included_modules.include?(RedmineFinance::Patches::CustomFieldsHelperPatch)
    CustomFieldsHelper.send(:include, RedmineFinance::Patches::CustomFieldsHelperPatch)
  end
end
