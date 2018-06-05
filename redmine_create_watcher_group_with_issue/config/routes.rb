# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :group_issue, only: [:new, :destroy]  do
  collection do
    post 'add_groups'
    get 'autocomplete_for_group'
  end
end