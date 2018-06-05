class CreateIssueEmailFooterIssues < ActiveRecord::Migration
  def change
    create_table :issue_email_footer_issues do |t|
      t.integer :issue_email_footer_id
      t.integer :issue_id
    end
    add_index :issue_email_footer_issues, [:issue_email_footer_id , :issue_id], unique: true, name: 'index_issue_email_footer_issue'
  end

  def down
    drop_table :issue_email_footer_issues
  end
end
