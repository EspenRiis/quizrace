Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Mount ActionCable
  mount ActionCable.server => '/cable'

  namespace :api do
    namespace :v1 do
      # Quizzes
      resources :quizzes, only: [:index, :show, :create, :update, :destroy] do
        resources :questions, only: [:index, :create, :update, :destroy]
      end

      # Rooms
      resources :rooms, only: [:create, :show] do
        member do
          get :status
          post :join
          post :start
        end
      end

      # Players
      resources :players, only: [:show]
    end
  end
end
