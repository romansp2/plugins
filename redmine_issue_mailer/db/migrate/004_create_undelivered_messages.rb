class CreateUndeliveredMessages < ActiveRecord::Migration
  def change
    create_table :undelivered_messages do |t|
      t.integer :issue_sent_on_client_email_id
      t.string :to_original_recipient
      t.string :message_report_id
      t.string :note
      t.timestamps null: false
    end
    add_index :undelivered_messages, ['issue_sent_on_client_email_id']
  end

  def down
    drop_table :undelivered_messages
  end
end
