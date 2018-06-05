class CreateProjectHotButtons < ActiveRecord::Migration
  def change
    create_table :project_hot_buttons do |t|
      t.belongs_to :project,     null: false
      t.belongs_to :hot_button,  null: false
    end
    add_index :project_hot_buttons, [:project_id, :hot_button_id], unique: true 
  end
end


