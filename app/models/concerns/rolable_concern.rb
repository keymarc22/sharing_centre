module RolableConcern
  extend ActiveSupport::Concern

  included do
    validates :role, inclusion: { in: Role::LIST }
    validates :role, presence: true
  end

  def can?(ability, action = nil)
    Role.can?(role, ability, action)
  end

  Role::LIST.each do |role_name|
    define_method "#{role_name}?" do
      role == role_name
    end
  end
end