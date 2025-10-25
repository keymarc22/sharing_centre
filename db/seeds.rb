Role::LIST.each do |role_name|
  User.find_or_create_by!(email: "#{role_name}@example.com") do |user|
    user.country_code = 'VE'
    user.name = role_name.capitalize
    user.password = 'password'
    user.role = role_name
  end
end