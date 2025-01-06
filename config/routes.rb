Rails.application.routes.draw do
  devise_for :users, defaults: { format: :json }
  namespace :api do
    namespace :v1 do
      resources :payments, only: [:create, :index]
    end
  end
end
