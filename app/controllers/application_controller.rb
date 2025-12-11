class ApplicationController < ActionController::Base
  include AuthorizationConcern

  before_action :authenticate_user!
  around_action :switch_locale

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def switch_locale(&action)
    requested = current_user.try(:locale) || params[:locale] || I18n.default_locale

    requested_str = requested.to_s
    available = I18n.available_locales.map(&:to_s)

    chosen = if available.include?(requested_str)
      requested_str.to_sym
    else
      I18n.default_locale
    end

    I18n.with_locale(chosen, &action)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path(locale: I18n.locale || I18n.default_locale)
  end
end
