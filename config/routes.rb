Rails.application.routes.default_url_options[:locale] = I18n.default_locale

Rails.application.routes.draw do
  root 'dashboard#index'
  get "/:locale" => "dashboard#index"

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  
  scope '/:locale', locale: /es|en/ do
    resources :students, only: %i[index show]
    resources :teachers, only: [:index]
  end
end
