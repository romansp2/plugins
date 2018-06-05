class CreateEmailBooks < ActiveRecord::Migration
  def change
    create_table :email_books do |t|
      t.integer :project_id
      t.string :name
      t.string :email
      t.timestamps null: false
    end
    add_index :email_books, [:project_id, :name], unique: true, name: 'index_project_name'
  end

   def down
    drop_table :email_books
  end
end
