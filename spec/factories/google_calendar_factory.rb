FactoryBot.define do
  factory :google_calendar do
    association :user
    calendar_id { "primary" }
    summary { "Primary Calendar" }
    time_zone { "America/New_York" }
    sync_token { nil }
    watch_channel_id { nil }
    watch_expires_at { nil }
    last_synced_at { nil }
    metadata { {} }
  end
end
