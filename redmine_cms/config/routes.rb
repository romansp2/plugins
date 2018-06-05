# This file is a part of Redmin CMS (redmine_cms) plugin,
# CMS plugin for redmine
#
# Copyright (C) 2011-2016 RedmineUP
# http://www.redmineup.com/
#
# redmine_cms is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_cms is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_cms.  If not, see <http://www.gnu.org/licenses/>.

# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get "/sitemap" => "cms_site#sitemap", :defaults => {:format => :xml}

match 'site/login', :to => 'cms_site#login', :as => 'cms_login', :via => [:get, :post]
match 'site/logout', :to => 'cms_site#logout', :as => 'cms_logout', :via => [:get, :post]
match 'site/register', :to => 'cms_site#register', :via => [:get, :post], :as => 'cms_register'
match 'site/lost_password', :to => 'cms_site#lost_password', :via => [:get, :post], :as => 'cms_lost_password'
match 'site/activate', :to => 'cms_site#activate', :via => :get
match 'site/expire_cache', :to => 'cms_site#expire_cache', :via => :get, :as => 'site_expire_cache'

get "projects/:project_id/pages/:tab" => "project_tabs#show", :as => "project_tab"
get 'cms_menus/parent_menu_options' => 'cms_menus#parent_menu_options'

scope '/cms' do
  resources :cms_pages, :path => 'pages' do
    member do
     get :preview
     get :expire_cache
    end
    collection do
      get :search
    end
  end
  resources :cms_parts, :path => 'parts' do
    member do
     get :expire_cache
     get :preview
    end
  end
  resources :cms_snippets, :path => 'snippets' do
    member do
      get :preview
    end
  end
  resources :cms_variables, :path => 'variables'
  resources :cms_layouts, :path => 'layouts' do
    member do
      get :preview
    end
  end
  resources :cms_assets, :path => 'assets', :except => [:edit, :update, :show]
  resources :cms_redmine_layouts, :path => 'redmine_layouts'
  resources :cms_menus, :path => 'menus'
  resources :cms_redirects, :path => 'redirects'
  resources :cms_settings, :path => 'settings' do
    collection do
      get 'redmine_hooks'
      post 'save'
    end
  end
  get "/:object_type/:id/history" => "cms_history#history", :as => "cms_object_history"
  get "/:object_type/:id/diff" => "cms_history#diff", :as => "cms_object_diff"
  get "/:object_type/:id/annotate" => "cms_history#annotate", :as => "cms_object_annotate"
  get 'assets/:id/(:filename)', :to => 'cms_assets#show', :id => /\d+/, :filename => /.*/, :as => 'named_asset'
  get 'assets/download/:id/:filename', :to => 'cms_assets#download', :id => /\d+/, :filename => /.*/, :as => 'download_named_asset'
  get 'assets/download/:id', :to => 'cms_assets#download', :id => /\d+/, :as => 'download_cms_asset'
  get 'assets/thumbnail/:id/:size/:filename', :to => 'cms_assets#thumbnail', :id => /\d+/, :filename => /.*/, :size => /\d+/, :as => 'cms_thumbnail'
  get 'assets/edit', :to => 'cms_assets#edit', :as => :cms_assets_edit
  post 'assets', :to => 'cms_assets#update', :as => :cms_assets_update

  # Export
  get 'exports/:object_type/:id(.:format)' => 'cms_exports#new', :as => :cms_export
  post 'exports/:object_type/:id' => 'cms_exports#create'
  get 'exports/website' => 'cms_exports#website', :as => :cms_export_website
  post 'exports/website' => 'cms_exports#website'

  # Import
  get 'imports/website' => 'cms_imports#website', :as => :cms_import_website
  post 'imports/website' => 'cms_imports#website'
  get 'imports/:object_type' => 'cms_imports#new', :as => :cms_import
  post 'imports/:object_type' => 'cms_imports#create'
end

get 'attachments/thumbnail/:id(/:size)/:filename', :controller => 'attachments', :action => 'thumbnail', :id => /\d+/, :filename => /.*/, :size => /\d+/
get 'pages/:page_id/parts/*name' => 'cms_parts#show', :as => "show_site_part"

get 'pages/*path' => 'cms_pages#show', :as => "show_site_page"
