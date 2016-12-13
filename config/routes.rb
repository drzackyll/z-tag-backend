Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:create, :index]
  resources :sessions, only: [:create]
  resources :markers, only: [:create, :index]
  resources :scores, only: [:index]
end
