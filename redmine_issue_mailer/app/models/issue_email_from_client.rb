class IssueEmailFromClient < ActiveRecord::Base
  unloadable
  belongs_to :project
  belongs_to :issue
  belongs_to :journal
end
