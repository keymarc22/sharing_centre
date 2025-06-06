class Student < User

  belongs_to :active_program, class_name: 'StudentProgram', optional: true

  has_many :student_programs
  has_many :programs, through: :student_programs
  has_many :book_lists, dependent: :destroy

  has_one :personalized_program

  STUDENT_DATA = YAML.load_file(Rails.root.join('lib/student_data.yml'))
  custom_fields = STUDENT_DATA['custom_data'].keys.map(&:to_sym)

  store_accessor :custom_data, *custom_fields

end