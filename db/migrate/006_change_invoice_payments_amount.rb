class ChangeInvoicePaymentsAmount < ActiveRecord::Migration
  ActiveRecord::Base.connection.tables
  if ActiveRecord::Base.connection.table_exists? 'invoice_payments'
    def up
      change_column :invoice_payments, :amount, :decimal, :precision => 16, :scale => 8, default: 0.0
    end

    def down
      change_column :invoice_payments, :amount, :decimal, precision: 10, scale: 2, default: 0.0
    end
  else
    puts 'Check Redmine Products plugin is available?'
  end
end