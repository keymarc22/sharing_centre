module RolableConcern
  extend ActiveSupport::Concern

  included do
    validates :role, inclusion: { in: Role::List }
    validates :role, presence: true
  end

  def can?(action)
    Role.can?(role, action)
  end

  ROLES.each do |role_name|
    define_method "#{role_name}?" do
      role == role_name
    end
  end
end