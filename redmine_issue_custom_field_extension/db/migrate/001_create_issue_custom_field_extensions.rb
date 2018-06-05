class CreateIssueCustomFieldExtensions < ActiveRecord::Migration
  def change
    create_table :issue_custom_field_extensions do |t|
      t.belongs_to :custom_field
      t.boolean    :extends,              default: false
      t.boolean    :notify,               default: false
      t.boolean    :add_as_watcher,       default: false
      t.string     :default_value,        default: '' 
      t.boolean    :visible,              default: false 
    end
  end

  def down
    drop_table :issue_custom_field_extensions
  end
end
