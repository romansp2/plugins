class CreateIssueEmailFromClients < ActiveRecord::Migration
  def change
    create_table :issue_email_from_clients do |t|
      t.integer :project_id
      t.integer :issue_id
      t.integer :journal_id
      t.string :message_id
      t.string :from
      t.string :subject
      t.string :to
      t.string :cc 
      t.timestamps null: false
    end
    add_index :issue_email_from_clients, ['project_id', 'issue_id' , 'journal_id'], name: 'index_project_issue_journal'
  end

  def down
    drop_table :issue_email_from_clients
  end
end
