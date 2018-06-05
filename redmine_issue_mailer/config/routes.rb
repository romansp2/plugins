# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :issue_mail_settings, only: [:index]
resources :issue_mail_server_settings
resources :write_letter_to_clients, only: [:new]

resources :issue_sent_on_client_emails, only: [:index, :show] do 
  collection do 
    get :show_from_issue
  end
end

resources :mail_handler_issue_client_tests, only: [:index]

resources :issue_email_from_clients, only: [:index, :show, :show_from_issue] do 
  collection do 
    get :show_from_issue
  end
end

resources :undelivered_messages, only: [:index, :show] do 
  collection do 
    get :show_from_issue
  end
end 

resources :issue_mailer_standard_fields

resources :issue_mailer_custom_fields

resources :issue_email_footers

resources :issue_email_footer_issues

resources :email_books