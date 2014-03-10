Spree::Core::Engine.routes.draw do
  namespace :admin do
    get 's3encrypt' => 'redactor#encrypt'
    post 'redactor_upload' => 'redactor#upload'
    resource :editor_settings, :only => ['show', 'update', 'edit']
  end
end
