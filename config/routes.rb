Spree::Core::Engine.routes.draw do
  namespace :admin do
  	get 's3' => 's3#index'
    resource :editor_settings, :only => ['show', 'update', 'edit']
  end
end
