class IssueCustomFieldExtensionMailerIssueAddWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :cust_field_ext_mailer_issue_add, :retry => false
      #include Redmine::I18n
      #include RoutesHelper
      #include GravatarHelper::PublicMethods
      #include Redmine::Pagination::Helper
      #include ActionView::Helpers::UrlHelper
      #include Rails.application.routes.url_helpers

  def perform(issue_str)

    issue_json = JSON.parse(issue_str)

    issue = Issue.new(issue_json, without_protection: true, :validate => false)

    users = issue.notified_users_from_custom_fields_for_new_issue
    
    unless users.empty?
      Mailer.issue_add(issue, users, []).deliver
    end
  end#def perform
end