FactoryBot.define do
  factory :class_session do
    teacher { create(:teacher) }
    student { create(:student) }
    lesson { nil }

    sequence(:title) { |n| "Class #{n}" }
    description { 'Test class description' }
    start_at { 1.hour.from_now }
    end_at { 2.hours.from_now }
    time_zone { 'UTC' }
    meet_link { nil }
    google_event_id { nil }
    google_calendar_owner_id { nil }

    trait :with_google_event do
      google_event_id { SecureRandom.uuid }
      google_calendar_owner_id { create(:teacher, :with_google_oauth).id }
    end
  end
end
