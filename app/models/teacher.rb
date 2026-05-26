class Teacher < User
  has_many :class_sessions, foreign_key: :teacher_id
end