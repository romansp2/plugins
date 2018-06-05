class CreateUsersFieldFromTos < ActiveRecord::Migration
  def change
    create_table :users_field_from_tos do |t|
      t.belongs_to :hot_button
      t.string     :fields_from_to, default: "{}"
    end
    add_index :users_field_from_tos, :hot_button_id
  end
end
