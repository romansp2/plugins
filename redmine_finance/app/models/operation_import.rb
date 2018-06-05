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


class OperationImport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include CSVImportable

  attr_accessor :file, :project, :quotes_type

  def klass
    Operation
  end

  def build_from_fcsv_row(row)
    ret = Hash[row.to_hash.map{ |k,v| [k.underscore.gsub(' ','_'), force_utf8(v)] }].delete_if{ |k,v| !klass.column_names.include?(k) }
    ret[:category_id] =  OperationCategory.named(row['operation type']).first.try(:id)
    ret[:account_id] =  project.accounts.named(row['account']).first.try(:id)
    if row['contact'].to_s.match(/^\#(\d+):/)
      ret[:contact_id] = Contact.find_by_id($1).try(:id)
    end
    ret[:operation_date] = Date.parse(row['operation date']) rescue Date.strptime(row['operation date'], '%m/%d/%Y')
    ret[:author] = User.current
    ret[:amount] = row['income'].to_i > 0 ? row['income'] : row['expense']
    ret[:id] = nil
    ret
  end

end
