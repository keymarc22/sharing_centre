class OmniauthInvalidError < StandardError; end
class GoogleOauthService
  
  # Returns the user or nil. Internally runs the authorization and returns the
  # result of #run! (which may raise OmniauthInvalidError when email is missing).
  def self.authorize!(auth)
    new(auth).send(:run!)
  end
  
  private
  def initialize(auth)
    @auth = auth
  end

  def run!
    return nil if @auth.nil?
    raise OmniauthInvalidError, "No email provided by Google" if @auth.info&.email.blank?
    
    user = User.from_omniauth(@auth)
    user if user.present? && user.persisted?
  end
end
