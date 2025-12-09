Rails.application.routes.default_url_options[:locale] = I18n.default_locale

Rails.application.routes.draw do
  root 'dashboard#index'
  get "/:locale" => "dashboard#index"

  scope '/:locale', locale: /es|en/ do
    devise_for :users, controllers: { sessions: 'users/sessions' }

    resources :students, only: %i[index show]
    resources :teachers, only: [:index]
  end
end
