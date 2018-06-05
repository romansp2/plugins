# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :context_menu_watchers, only: [:new, :create] do 
  collection do
    get :autocomplete_for_user
    delete :destroy
  end  
end