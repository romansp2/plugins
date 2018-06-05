class CreateIssueMailerCustomFieldValues < ActiveRecord::Migration
  def change
    create_table :issue_mailer_custom_field_values do |t|
      t.integer :project_id
      #t.integer :custom_field_id
      t.text    :value
    end

    add_index :issue_mailer_custom_field_values, ['project_id']
    #add_index :issue_mailer_custom_field_values, ['custom_field_id']
  end

  def down
    drop_table :issue_mailer_custom_field_values
  end
end
