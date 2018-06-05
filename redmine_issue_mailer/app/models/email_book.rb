class EmailBook < ActiveRecord::Base
  unloadable

  belongs_to :project

  validates :name, :email, :project_id, presence: true
  validates_uniqueness_of :name, :scope => [:project_id]
end
