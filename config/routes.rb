Rails.application.routes.draw do
  root "pages#index"
  defaults format: :json do
    resources :users, only: %i[create]
    resource :session, only: %i[create destroy]
  end
end
