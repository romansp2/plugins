# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html



resources :ccwi_contacts_issues, only: [:new, :destroy]  do
  collection do
    post 'add_contacts'
    get 'autocomplete_for_contact'
  end
end