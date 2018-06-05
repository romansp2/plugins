class IssueEmailFooterIssue < ActiveRecord::Base
  unloadable
  belongs_to :issue
  belongs_to :issue_email_footer

  #has_one :issue
  #has_one :issue_email_footer
  
  validates :issue_email_footer_id, :issue_id, presence: true
  validates_uniqueness_of :issue_email_footer_id, :scope => [:issue_id]
end
