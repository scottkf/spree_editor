Spree::Core::Engine.routes.draw do
  namespace :admin do
  	get 's3' => 's3#index'
    get 's3encrypt' => 's3#encrypt'
    resource :editor_settings, :only => ['show', 'update', 'edit']
  end
end
