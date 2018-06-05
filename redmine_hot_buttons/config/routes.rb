# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :hot_buttons do 
  collection do
    #get  :hot_buttons_list
    #post :set_issue
    post :update_form
    put  :update_form
  end
end

#post 'hot_buttons/update_form/:project_id', to: 'hot_buttons#update_form', format: true, constraints: {format: 'js'}

resources :hot_button_issue do 
  collection do 
    post :set_issue_to
  end
end

patch 'issues/hot_button_update_form/:hot_button_id', :to => 'issues#hot_button_update_form', :as => 'hot_button_update_form'


