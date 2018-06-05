class AddForTrackerIdToHotButtons < ActiveRecord::Migration
  def change
    add_column :hot_buttons, :for_tracker_id, :integer
  end

  def down
    remove_column :hot_buttons, :for_tracker_id
  end
end