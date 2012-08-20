Neuroanatomist::Application.routes.draw do

  resources :nodes
  resources :sections

  resources :bibliographies
  resources :resources
  resources :resource_types

  resources :tags
  resources :ratings

  resources :perspectives
  resources :region_styles
  
  resources :types, :path => "/ontology/types"
  resources :things, :path => "/ontology/things"
  resources :relations, :path => "/ontology/relations"
  resources :facts, :path => "/ontology/facts"
  resources :ontology

  root :to => 'home#index'
  
  resources :shape_sets
  resources :shapes
  resources :meshes
  
  resources :regions
  resources :region_definitions
  resources :decompositions

  match "/jaxdata(/:shape_set_id)" => "jax_data#fetch", :as => :jax_data
  match "/jaxdata/c/:cache_id" => "jax_data#fetch_partial_response", :as => :jax_data
  match "/jaxdata/i/:shape_set_id" => "jax_data#fetch_shape_set_ids", :as => :jax_data
  
  
  mount Jax::Engine => "/jax" unless Rails.env == "production"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
