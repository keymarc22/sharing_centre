Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root 'dashboard#index'

  get '/:locale' => 'dashboard#index'

  scope '/:locale', locale: /es|en/ do
    devise_for :users, controllers: { sessions: 'users/sessions' }
  end
end
