class IssueCustomFieldExtensionMailerIssueAddWatchersWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :cust_field_ext_mailer_issue_add, :retry => false
      #include Redmine::I18n
      #include RoutesHelper
      #include GravatarHelper::PublicMethods
      #include Redmine::Pagination::Helper
      #include ActionView::Helpers::UrlHelper
      #include Rails.application.routes.url_helpers

  def perform(issue_str, user_ids_str)

    issue_json = JSON.parse(issue_str)
    user_ids = JSON.parse(user_ids_str)
    
    issue = Issue.new(issue_json, without_protection: true, :validate => false)

    users = User.where("users.id IN (?)", user_ids)
    
    unless users.empty?
      Mailer.issue_add(issue, users, []).deliver
    end
  end#def perform
end