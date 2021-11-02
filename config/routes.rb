require 'sidekiq/web'

Rails.application.routes.draw do

  mount Sidekiq::Web => '/sidekiq'
  
  devise_for :users, defaults: { format: :json }, controllers: {
    sessions: 'sessions',
    registrations: 'registrations',
    confirmations: 'confirmations',
    passwords: 'passwords',
  }

  # API V1
  host_regex = DomainHelper.needs_api_subdomain? ? '^api' : ''
  constraints host: /#{host_regex}/ do
    namespace :v1, defaults: { format: :json } do
      resources :messages, only: [:create, :update, :destroy]
      resources :cards, except: [:new, :edit]
      post 'send', to: 'cards#send'
      resources :magic_links, only: [:create, :show]
    end
  end
end
