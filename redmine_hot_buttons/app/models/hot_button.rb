class HotButton < ActiveRecord::Base
  unloadable
  has_many   :project_hot_buttons, :dependent => :destroy
  has_many   :projects, :through => :project_hot_buttons
  has_one    :users_field_from_to, :dependent => :destroy
  belongs_to :tracker
  belongs_to :for_tracker, :class_name => 'Tracker',    :foreign_key => 'for_tracker_id'
  belongs_to :status,   :class_name => 'IssueStatus',   :foreign_key => 'status_id'
  belongs_to :priority, :class_name => 'IssuePriority', :foreign_key => 'priority_id'
  belongs_to :role
  belongs_to :category, :class_name => 'IssueCategory', :foreign_key => 'category_id'

  validates :name,     presence: true
  validates :tracker,  presence: true
  validates :status,   presence: true
  #validates :priority, presence: true
  validates :role,     presence: true

  validates_associated  :users_field_from_to
  validates_presence_of :users_field_from_to, message: "You do not set settigns for fields Assigned to, Custom Fields"
end
