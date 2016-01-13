Rails.application.routes.draw do

  root 'home#index'

  resources :users do
    member do
      get 'profile'
      get 'matches'
    end
  end

  get 'auth/:provider/callback', to: 'sessions#create'
  match 'sign_out', to: 'sessions#destroy', via: :delete

  post 'create_friendships' => 'friendships#create'
  delete 'destroy_friendships' => 'friendships#destroy'
end
