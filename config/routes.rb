Rails.application.routes.draw do
  devise_for :users,
    defaults: { format: :json },
    controllers: {
      sessions: 'api/v1/sessions',
      registrations: 'api/v1/registrations'
    }
  
  namespace :api do
    namespace :v1 do
      resources :payments, only: [:create, :index]
    end
  end
end
