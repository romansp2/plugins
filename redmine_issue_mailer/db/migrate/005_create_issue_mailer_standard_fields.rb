class CreateIssueMailerStandardFields < ActiveRecord::Migration
  def change
    create_table :issue_mailer_standard_fields do |t|
      t.integer :project_id, :null => false	
      t.integer :tracker_id	
      t.integer :category_id
      t.integer :status_id
      t.integer :assigned_to_id
      t.integer :priority_id
      t.integer :fixed_version_id
      t.datetime :start_date
      t.datetime :due_date
      t.float    :estimated_hours
      t.integer  :done_ratio, :default => 0, :null => false
    end
    add_index :issue_mailer_standard_fields, ['project_id']
  end
end



