class CreateIssueMailServerSettings < ActiveRecord::Migration
  def change
    create_table :issue_mail_server_settings do |t|
      t.integer :project_id, null: false
      t.string  :adress
      t.integer :port
      t.string  :authentication
      t.string  :domain
      t.string  :user_name,    null: false
      t.string  :protocol,     null: false,  :limit => 10
      t.string  :password
      t.boolean :enable_starttls_auto, default: false 
      t.string  :openssl_verify_mode
      t.boolean :ssl, default: false 
      t.boolean :tls, default: false 
      t.timestamps null: false
    end
    add_index :issue_mail_server_settings, [:project_id]
  end
end
