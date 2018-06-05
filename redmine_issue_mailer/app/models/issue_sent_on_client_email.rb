class IssueSentOnClientEmail < ActiveRecord::Base
  unloadable
  belongs_to :project
  belongs_to :issue 
  belongs_to :journal
  has_many :undelivered_messages

  validates :to,   presence: true
  validates :from, presence: true
end
