# encoding: utf-8
#
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

module OperationsHelper
  def operation_categories_for_select(selected = nil)
    @operation_categories ||= OperationCategory.order(:lft).all
  end

  def operation_types_for_select(income)
    s = ''
    s << %Q(<option #{'selected="selected"' if income == true} value="1">#{ l(:label_operation_income) }</option>).html_safe
    s << %Q(<option #{'selected="selected"' if income == false} value="0">#{ l(:label_operation_expense) }</option>).html_safe
    s.html_safe
  end

  def operation_category_tree_options_for_select(operation_categories, options = {})
    s = ''
    OperationCategory.category_tree(operation_categories) do |operation_category, level|
      name_prefix = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
      tag_options = {:value => operation_category.id}
      if operation_category == options[:selected] || (options[:selected].respond_to?(:include?) && options[:selected].include?(operation_category))
        tag_options[:selected] = 'selected'
      else
        tag_options[:selected] = nil
      end
      tag_options.merge!(yield(operation_category)) if block_given?
      s << content_tag('option', name_prefix + h(operation_category.name), tag_options)
    end
    s.html_safe
  end

  def operation_category_url(category_id, options={})
    {:controller => 'operations',
     :action => 'index',
     :set_filter => 1,
     :project_id => @project,
     :fields => [:category_id],
     :values => {:category_id => [category_id]},
     :operators => {:category_id => '='}}.merge(options)
  end

  def operation_category_tree_tag(operation, options={})
    return "" if operation.category.blank?
    operation.category.self_and_ancestors.map do |category|
      link_to category.name, operation_category_url(category.id, options)
    end.join(' &#187; ').html_safe
  end

  def account_tag(account, options={})
    link_to account.name, account_path(account)
  end

  def opeation_tag(operation, options={})
    link_to operation.to_s, account_path(account)
  end

  def operation_list_styles_for_select
    list_styles = [[l(:label_crm_list_list), "list"]]
    list_styles += [[l(:label_calendar), "crm_calendars/crm_calendar"]]
  end

  def operations_list_style
    list_styles = operation_list_styles_for_select.map(&:last)
    if params[:operations_list_style].blank?
      list_style = list_styles.include?(session[:operations_list_style]) ? session[:operations_list_style] : list_styles.first
    else
      list_style = list_styles.include?(params[:operations_list_style]) ? params[:operations_list_style] : list_styles.first
    end
    session[:operations_list_style] = list_style
  end

  def operations_contacts_for_select(project)
    scope = Contact.where({})
    scope = scope.joins(:projects).uniq.where(Contact.visible_condition(User.current))
    scope = scope.joins(:operations => :account)
    scope = scope.where(:accounts => {:project_id => project}) if project
    scope.limit(500).map{|c| [c.name, c.id.to_s]}
  end

  def account_current_balance(previous_balance, operation)
    return previous_balance if RedmineFinance.operations_approval? && !operation.is_approved?
    previous_balance - (operation.is_income? ? operation.amount : -operation.amount)
  end

  def disapproved_operations_url(is_income, options={})
    {:controller => 'operations',
     :action => 'index',
     :set_filter => 1,
     :project_id => @project,
     :fields => [:is_approved, :operation_type],
     :values => {:is_approved => ["0"], :operation_type => [is_income ? "1" : "0"]},
     :operators => {:is_approved => '=', :operation_type => '='}}.merge(options)
  end

  def accounts_for_select(project)
    scope = project ? project.accounts : Account.where({})
    scope.all.map{|a| ["#{a.name} (#{a.currency})", a.id.to_s]}
  end

  def operations_balance_to_currency(income_sum, expense_sum)
    currencies = income_sum.map{|a| a[0]} | expense_sum.map{|a| a[0]}
    currencies.map{|a| price_to_currency(income_sum[a].to_f - expense_sum[a].to_f, a)}.join('<br/>').html_safe
    # operations_balance.map{|c| c[0][1].to_i - c[1][1].to_f}
  end

  def operations_to_csv(operations)
    decimal_separator = l(:general_csv_decimal_separator)
    encoding = l(:general_csv_encoding)
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      # csv header fields
      headers = [ "#",
                  'Operation date',
                  'Income',
                  'Expense',
                  'Operation type',
                  'Account',
                  'Description',
                  'Contact',
                  'Created',
                  'Updated'
                  ]
      custom_fields = OperationCustomField.all
      custom_fields.each {|f| headers << f.name}
      # Description in the last column
      csv << headers.collect {|c| Redmine::CodesetUtil.from_utf8(c.to_s, encoding) }
      # csv lines
      operations.each do |operation|
        fields = [operation.id,
                  format_time(operation.operation_date),
                  operation.is_income? ? operation.amount : "",
                  operation.is_income? ? "" :  operation.amount,
                  operation.category ? operation.category.name : "",
                  operation.account.name,
                  operation.description,
                  operation.contact,
                  format_time(operation.created_at),
                  format_time(operation.updated_at)
                  ]
        custom_fields.each {|f| fields << RedmineContacts::CSVUtils.csv_custom_value(operation.custom_value_for(f)) }
        csv << fields.collect {|c| Redmine::CodesetUtil.from_utf8(c.to_s, encoding) }
      end
    end
    export
  end
  def importer_link
    project_operation_imports_path(:project_id => @project)
  end

  def importer_show_link(importer, project)
    project_operation_import_path(:id => importer, :project_id => project)
  end

  def importer_settings_link(importer, project)
    settings_project_operation_import_path(:id => importer, :project => project)
  end

  def importer_run_link(importer, project)
    run_project_operation_import_path(:id => importer, :project_id => project, :format => 'js')
  end

  def importer_link_to_object(operation)
    link_to operation.description, edit_operation_path(operation)
  end
end
