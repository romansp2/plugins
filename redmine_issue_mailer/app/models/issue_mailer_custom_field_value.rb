class IssueMailerCustomFieldValue < ActiveRecord::Base
  unloadable
  include ActiveModel::Serialization
  serialize :value
  
  validates :project_id, uniqueness: true 
  belongs_to :project
  belongs_to :custom_field
end
