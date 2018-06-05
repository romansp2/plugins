class CreateIssueSentOnClientEmails < ActiveRecord::Migration
  def change
    create_table :issue_sent_on_client_emails do |t|
      t.integer :project_id
      t.integer :issue_id
      t.integer :journal_id
      t.string :message_id
      t.string :from
      t.string :to
      t.string :bcc
      t.string :cc 
      t.string :subject
      t.text   :body
      t.boolean :deliver, default: false

      t.timestamps null: false
    end
    add_index :issue_sent_on_client_emails, ['project_id', 'issue_id' , 'journal_id'], name: 'index_project_issue_journal'

  end

  def down
    drop_table :issue_sent_on_client_emails
  end
end
