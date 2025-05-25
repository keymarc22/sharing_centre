FactoryBot.define do
  factory :user do
    name { 'Test' }
    sequence(:email) { |n| "email-#{n}@example.com" }
    country_code { 'VE' }
    password { 123456789 }

    factory :student, class: 'Student' do
      type { 'Student' }

      trait :with_student_program do
        after(:create) do |student|
          create(:student_program, student: student)
        end
      end
    end

    factory :teacher do
      type { 'Teacher' }
    end

    factory :administrative do
      type { 'Administrative' }
    end

    factory :owner do
      type { 'Owner' }
    end
  end
end