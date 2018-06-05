class WriteLetterToClientsController < ApplicationController
  unloadable
  #before_filter :find_project_by_project_id, :authorize
  before_filter :find_issue_by_issue_id, :authorize

  def new
  	@footers = @project.issue_email_footers
  	@default_footer = @issue.issue_email_footer || @footers.first

  	@permission_for_to_field = []
    @email_book = []
    @email_books = []

    @client_email = nil

  	if User.current.allowed_to?(:write_letter_to_client, @project)
      @client_email = @issue.issue_email_from_clients.first
      #@client_emails = @issue.issue_email_from_clients.select('DISTINCT(issue_email_from_clients.from), issue_email_from_clients.id, issue_email_from_clients.issue_id, issue_email_from_clients.journal_id')
      #@client_emails_options_for_select = @client_emails.map do |client_email| 
      #                                      name = (client_email.journal_id.nil? ? "Client (Issue)" : "Client JournalID#{client_email.journal_id}") 
      #                                      [client_email.id, name]
      #                                    end
      (@permission_for_to_field << [ l(:author_of_request, scope: [:redmine_issue_mailer]), "1"]) unless @client_email.nil?
  	end
  	if User.current.allowed_to?(:write_letter_to_email_from_book_of_e_mail_address, @project)
      @permission_for_to_field << [ l(:email_from_book_of_email_address, scope: [:redmine_issue_mailer]), "2"]
      @email_books = @project.email_books
  	end
  	if User.current.allowed_to?(:write_letter_without_restriction, @project)
  	  @permission_for_to_field << [ l(:write_email_adress, scope: [:redmine_issue_mailer]), "3"]
  	end
  end
  
end
