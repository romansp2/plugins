class ChangeProductLinesPrice < ActiveRecord::Migration
  ActiveRecord::Base.connection.tables
  if ActiveRecord::Base.connection.table_exists? 'product_lines'
    def up
      change_column :product_lines, :price, :decimal, :precision => 16, :scale => 8, default: 0.0
    end

    def down
      change_column :product_lines, :price, :decimal, precision: 10, scale: 2, default: 0.0
    end
  else
    puts 'Check Redmine Products plugin is available?'
  end
end
