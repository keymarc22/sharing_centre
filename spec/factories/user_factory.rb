FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "email-#{n}@example.com" }
    name         { 'Test' }
    country_code { 'MX' }
    password     { 123456789 }
    role         { 'student' }

    trait :teacher do
      role { 'teacher' }
    end

    trait :student do
      role { 'student' }
    end

    trait :admin do
      role { 'admin' }
    end

    trait :with_google_oauth do
      provider { 'google_oauth2' }
      uid { SecureRandom.uuid }
      google_access_token { 'access_token_123' }
      google_refresh_token { 'refresh_token_123' }
      google_token_expires_at { 1.hour.from_now }
    end
  end

  factory :teacher, class: 'Teacher' do
    sequence(:email) { |n| "teacher-#{n}@example.com" }
    name         { 'Teacher' }
    country_code { 'MX' }
    password     { 123456789 }
    role         { 'teacher' }

    trait :with_google_oauth do
      provider { 'google_oauth2' }
      uid { SecureRandom.uuid }
      google_access_token { 'access_token_123' }
      google_refresh_token { 'refresh_token_123' }
      google_token_expires_at { 1.hour.from_now }
    end

    trait :with_student_program do
      # N/A for teachers
    end
  end

  factory :student, class: 'Student' do
    sequence(:email) { |n| "student-#{n}@example.com" }
    name         { 'Student' }
    country_code { 'MX' }
    password     { 123456789 }
    role         { 'student' }

    trait :with_student_program do
      after(:create) do |student|
        create(:student_program, student: student)
      end
    end

    trait :with_google_oauth do
      provider { 'google_oauth2' }
      uid { SecureRandom.uuid }
      google_access_token { 'access_token_123' }
      google_refresh_token { 'refresh_token_123' }
      google_token_expires_at { 1.hour.from_now }
    end
  end
end