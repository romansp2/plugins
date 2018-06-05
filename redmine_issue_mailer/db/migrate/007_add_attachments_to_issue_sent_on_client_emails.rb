class AddAttachmentsToIssueSentOnClientEmails < ActiveRecord::Migration
  def change
    add_column :issue_sent_on_client_emails, :attachments, :boolean, default: false
  end

  def down
    remove_column :issue_sent_on_client_emails, :attachments
  end
end
