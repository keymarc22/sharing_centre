require 'rails_helper'

RSpec.describe GoogleCalendar, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:class_sessions) }
    it { should have_many(:google_watch_channels) }
  end

  describe 'validations' do
    it { should validate_presence_of(:calendar_id) }
    
    # uniqueness validation requires existing record
    pending 'validates uniqueness of calendar_id scoped to user_id'
  end

  describe '#watch_active?' do
    pending 'returns true when watch channel is active and not expired'
    pending 'returns false when watch channel has expired'
    pending 'returns false when watch_channel_id is nil'
  end

  describe '#update_sync_token!' do
    pending 'updates sync_token and last_synced_at'
  end

  describe '#clear_sync_token!' do
    pending 'clears the sync_token'
  end
end
