# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
resources :context_menu_watcher_groups, only: [:new, :create] do 
  collection do
    get :autocomplete_for_group
    delete :destroy
  end  
end