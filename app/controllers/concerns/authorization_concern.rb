module AuthorizationConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_can?
  end

  def current_user_can?(resource, action = :manage)
    return false unless respond_to?(:current_user) && current_user
    Role.can?(current_user.role, resource, action)
  end

  # Lanza una respuesta apropiada si no tiene permiso (redirige o responde 403)
  def authorize!(resource, action = :manage)
    return if current_user_can?(resource, action)

    respond_to do |format|
      format.html { redirect_to(root_path, alert: t('authorization.unauthorized', default: 'No autorizado')) }
      format.json { head :forbidden }
      format.any  { head :forbidden }
    end
  end
end