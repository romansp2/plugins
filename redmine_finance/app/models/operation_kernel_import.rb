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

class OperationKernelImport < Import

  def klass
    Operation
  end

  def saved_objects
    object_ids = saved_items.pluck(:obj_id)
    Operation.where(:id => object_ids).order(:id)
  end

  def project=(project)
    settings['project'] = project.id
  end

  def project
    settings['project']
  end

  private

  def build_object(row)
    operation = Operation.new
    operation.is_approved = true
    operation.author = user

    attributes = {}
    if income = row_value(row, 'income')
      attributes['amount'] = income.to_f
      attributes['income'] = true
    end

    if expense = row_value(row, 'expense')
      attributes['amount'] = expense.to_f
      attributes['income'] = false
    end

    if category = row_value(row, 'category')
      attributes['category_id'] = OperationCategory.where(:name => category).first.try(:id)
    end

    if account = row_value(row, 'account')
      attributes['account_id'] = Account.where(:name => account).first.try(:id)
    end

    if operation_date = row_value(row, 'operation_date')
      attributes['operation_date'] = Time.zone.parse(operation_date)
    end

    if description = row_value(row, 'description')
      attributes['description'] = description
    end

    if contact = row_value(row, 'contact')
      attributes['contact_id'] = Contact.by_full_name(contact).first.try(:id)
    end

    attributes['custom_field_values'] = operation.custom_field_values.inject({}) do |h, v|
      value = case v.custom_field.field_format
              when 'date'
                row_date(row, "cf_#{v.custom_field.id}")
              else
                row_value(row, "cf_#{v.custom_field.id}")
              end
      if value
        h[v.custom_field.id.to_s] = v.custom_field.value_from_keyword(value, operation)
      end
      h
    end

    operation.send :safe_attributes=, attributes, user
    operation
  end

end
