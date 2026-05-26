Rails.application.routes.draw do

  root 'dashboard#index'
  get "/:locale" => "dashboard#index"

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations'
  }

  scope '/:locale', locale: /es|en/ do
    resources :students, only: %i[index show]
    resources :teachers, only: [:index]
    resources :class_sessions, only: [:index], path: 'classes', as: :classes
    resources :calendars, only: [:index, :new, :create, :update, :destroy] do
      collection do
        post :sync
        get :navigate
      end
    end
  end
end
