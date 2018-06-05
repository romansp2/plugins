class IssueMailerStandardField < ActiveRecord::Base
  unloadable
  validates :project_id, uniqueness: true 
  belongs_to :project
  belongs_to :assigned_to, :class_name => 'Principal', :foreign_key => 'assigned_to_id'
end
