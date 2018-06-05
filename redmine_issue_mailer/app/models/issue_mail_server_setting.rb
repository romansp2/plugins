class IssueMailServerSetting < ActiveRecord::Base
  unloadable
  belongs_to :project

  validates :project_id, :user_name, :adress, presence: true
  validates :user_name, :uniqueness => true
  
  validates_confirmation_of :password
end
