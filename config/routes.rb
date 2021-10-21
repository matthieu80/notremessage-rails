Rails.application.routes.draw do

  # API V1
  host_regex = DomainHelper.needs_api_subdomain? ? '^api' : ''
  constraints host: /#{host_regex}/ do
    namespace :v1, defaults: { format: :json } do
      get '/', to: 'index#yoyo'
    end
  end

end
