class ChangeInvoiceAmount < ActiveRecord::Migration
  ActiveRecord::Base.connection.tables
  if ActiveRecord::Base.connection.table_exists? 'invoices'
    def up
      change_column :invoices, :amount, :decimal, :precision => 16, :scale => 8, default: 0.0
    end

    def down
      change_column :invoices, :amount, :decimal, precision: 10, scale: 2, default: 0.0
    end
  else
    puts 'Check Redmine Products plugin is available?'
  end
end