Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root 'dashboard#index'

  # Google Calendar push notifications webhook
  post '/google/calendar/push', to: 'google_push#receive'

  get '/:locale' => 'dashboard#index'

  scope '/:locale', locale: /es|en/ do
    devise_for :users, controllers: { sessions: 'users/sessions' }
    
    # Admin routes
    namespace :admin do
      resources :google_calendars, only: [:index] do
        member do
          post :sync_now
          post :fetch_event
        end
        collection do
          post :sync_all
        end
      end
    end
  end
end
