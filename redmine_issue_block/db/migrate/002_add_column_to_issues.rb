class AddColumnToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :block,             :boolean, default: false
    add_column :issues, :block_permissions, :text
  end

  def self.down
    remove_column :issues, :block
    remove_column :issues, :block_permissions 
  end
end
