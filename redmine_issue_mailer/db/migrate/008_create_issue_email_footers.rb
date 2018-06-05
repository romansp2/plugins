class CreateIssueEmailFooters < ActiveRecord::Migration
  def change
    create_table :issue_email_footers do |t|
      t.integer :project_id
      t.text :footer
    end
    add_index :issue_email_footers, [:project_id]
  end

  def down
    drop_table :issue_email_footers
  end
end
