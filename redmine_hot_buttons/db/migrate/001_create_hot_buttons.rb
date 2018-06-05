class CreateHotButtons < ActiveRecord::Migration
  def change
    create_table :hot_buttons do |t|
      t.string     :name,     null: false
      t.belongs_to :role,     null: false
      t.belongs_to :tracker,  null: false
      t.belongs_to :status,   null: false
      t.belongs_to :priority
      t.belongs_to :category
    end
    add_index :hot_buttons, :role_id
    add_index :hot_buttons, :tracker_id
    add_index :hot_buttons, :status_id
  end

  def down
    drop_table :hot_buttons
  end
end
