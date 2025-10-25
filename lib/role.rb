class Role
  LIST = %w[admin teacher superadmin student].freeze

  def self.can?(role, resource, action)
    return true if role == 'superadmin'

    defs = @roles || {}
    role_def = defs[role.to_sym] || defs[role.to_s.to_sym]
    return false unless role_def

    role_def.allows?(resource.to_sym, action)
  end

  class RoleDefinition
    def initialize(&block)
      @permissions = {}
      instance_eval(&block) if block_given?
    end

    # can :resource                    => permite todo (manage)
    # can :resource, only: [:show]     => permite acciones concretas
    def can(resource, only: nil)
      key = resource.to_sym

      @permissions[key] ||= []
      if only
        Array(only).each { |a| @permissions[key] << a.to_sym }
      else
        @permissions[key] << :manage
      end
      @permissions[key].uniq!
    end

    def allows?(resource, action = nil)
      return false unless @permissions.key?(resource)
      return true if @permissions[resource].include?(:manage)
      return false if action.nil?

      @permissions[resource].include?(action.to_sym)
    end

    attr_reader :permissions
  end

  private

  def self.role(name, &block)
    @roles ||= {}
    @roles[name] = RoleDefinition.new(&block)
  end

  role :admin do
    can :dashboard
    can :book_lists
    can :books
    can :lesson_topics
    can :lessons
    can :personalized_programs
    can :personalized_program_topics
    can :program_intervals
    can :programs
    can :students
    can :study_intervals
    can :teachers
    can :classes
  end

  role :teacher do
    can :dashboard
    can :book_lists
    can :books
    can :lesson_topics
    can :lessons
    can :personalized_programs
    can :personalized_program_topics
    can :classes
  end

  role :student do
    can :dashboard
    can :personalized_programs, only: [:show]
    can :personalized_program_topics, only: [:show]
    can :study_intervals
    can :student_programs, only: [:show]
    can :lessons, only: [:show]
    can :books, only: [:show]
    can :book_lists, only: [:show]
    can :teachers, only: [:show]
    can :classes, only: [:show]
  end
end