require 'sidekiq/web'

Rails.application.routes.draw do

  mount Sidekiq::Web => '/sidekiq'
  
  devise_for :users, defaults: { format: :json }, controllers: {
    sessions: 'sessions',
    registrations: 'registrations',
    confirmations: 'confirmations',
    passwords: 'passwords'
  }

  devise_scope :user do
    post '/magic_links', to: 'sessions#send_magic_link_email'
    get '/magic_links/verify', to: 'sessions#magic_link_verify'
  end

  # API V1
  host_regex = DomainHelper.needs_api_subdomain? ? '^api' : ''
  constraints host: /#{host_regex}/ do
    namespace :v1, defaults: { format: :json } do
      resources :messages, only: [:create, :update, :destroy]
      resources :cards, except: [:new, :edit] do
        member do
          post '/send', to: 'cards#send_by_email'
        end
      end
      resources :users, only: [:show, :update]
    end
  end
end
