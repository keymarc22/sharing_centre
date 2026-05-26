User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.country_code = 'VE'
  user.name = 'Admin'
  user.password = 'password'
  user.role = 'admin'
end

User.find_or_create_by!(email: 'superadmin@example.com') do |user|
  user.country_code = 'VE'
  user.name = 'Superadmin'
  user.password = 'password'
  user.role = 'superadmin'
end

3.times do |i|
  Teacher.find_or_create_by!(email: "teacher#{i + 1}@example.com") do |teacher|
    teacher.country_code = 'VE'
    teacher.name = "Teacher #{i + 1}"
    teacher.password = 'password'
    teacher.role = 'teacher'
  end
end

5.times do |i|
  Student.find_or_create_by!(email: "student#{i + 1}@example.com") do |student|
    student.country_code = 'VE'
    student.name = "Student #{i + 1}"
    student.password = 'password'
    student.role = 'student'
  end
end
