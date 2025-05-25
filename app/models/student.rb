class Student < User

  has_many :student_programs
  has_many :programs, through: :student_programs
  belongs_to :active_program, class_name: 'StudentProgram', optional: true

  STUDENT_DATA = YAML.load_file(Rails.root.join('lib/student_data.yml'))
  custom_fields = STUDENT_DATA['custom_data'].keys.map(&:to_sym)

  store_accessor :custom_data, *custom_fields

end