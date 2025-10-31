FactoryBot.define do
  factory :google_watch_channel do
    association :google_calendar
    channel_id { SecureRandom.uuid }
    resource_id { "resource_#{SecureRandom.hex(8)}" }
    resource_uri { "https://www.googleapis.com/calendar/v3/calendars/primary/events" }
    expires_at { 7.days.from_now }
    metadata { {} }
    
    trait :expired do
      expires_at { 1.day.ago }
    end
    
    trait :expiring_soon do
      expires_at { 12.hours.from_now }
    end
  end
end
