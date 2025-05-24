class Student < User

  STUDENT_DATA = YAML.load_file(Rails.root.join('lib/student_data.yml'))
  custom_fields = STUDENT_DATA['custom_data'].keys.map(&:to_sym)

  store_accessor :custom_data, *custom_fields

end