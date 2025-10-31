FactoryBot.define do
  factory :class_session do
    association :teacher, factory: :user
    association :student, factory: :user
    title { "English Lesson" }
    description { "A regular English lesson" }
    start_at { 1.day.from_now }
    end_at { 1.day.from_now + 1.hour }
    time_zone { "UTC" }
    status { :scheduled }
    
    trait :completed do
      status { :completed }
      start_at { 1.day.ago }
      end_at { 1.day.ago + 1.hour }
    end
    
    trait :cancelled do
      status { :cancelled }
    end
    
    trait :with_google_event do
      google_event_id { "event_#{SecureRandom.hex(8)}" }
      google_event_raw { { "id" => google_event_id, "summary" => title } }
      google_event_etag { "etag_#{SecureRandom.hex(4)}" }
      google_event_updated_at { Time.current }
      last_synced_at { Time.current }
    end
  end
end
