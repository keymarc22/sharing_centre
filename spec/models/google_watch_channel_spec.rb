require 'rails_helper'

RSpec.describe GoogleWatchChannel, type: :model do
  describe 'associations' do
    it { should belong_to(:google_calendar) }
  end

  describe 'validations' do
    it { should validate_presence_of(:channel_id) }
    it { should validate_presence_of(:resource_id) }
    it { should validate_presence_of(:resource_uri) }
    it { should validate_presence_of(:expires_at) }
    
    pending 'validates uniqueness of channel_id'
  end

  describe '#active?' do
    pending 'returns true when expires_at is in the future'
    pending 'returns false when expires_at is in the past'
  end

  describe '#expiring_soon?' do
    pending 'returns true when expires within 1 day'
    pending 'returns false when expires after 1 day'
  end
end
