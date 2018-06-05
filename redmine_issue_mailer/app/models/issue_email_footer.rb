class IssueEmailFooter < ActiveRecord::Base
  unloadable
  belongs_to :project

  has_many :issue_email_footer_issues, :dependent => :destroy
  has_many :issues, through: :issue_email_footer_issue

  #has_many_belongs_to_many :issue, :limit=>1, :class => "IssueEmailFooterIssue"

  validates :footer, presence: true
end
