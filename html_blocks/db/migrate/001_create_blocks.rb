class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|

      t.string :text

      t.string :address

      t.integer :link_type, :default => 0


    end

  end
end
