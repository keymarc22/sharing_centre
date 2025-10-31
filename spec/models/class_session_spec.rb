require 'rails_helper'

RSpec.describe ClassSession, type: :model do
  describe 'associations' do
    it { should belong_to(:teacher).class_name('User') }
    it { should belong_to(:student).class_name('User').optional }
    it { should belong_to(:owner_user).class_name('User').optional }
    it { should belong_to(:owner_calendar).class_name('GoogleCalendar').optional }
    it { should belong_to(:parent_session).class_name('ClassSession').optional }
    it { should have_many(:child_sessions).class_name('ClassSession') }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:start_at) }
    it { should validate_presence_of(:end_at) }
  end

  describe '.sync_from_google_event' do
    pending 'syncs a Google Calendar event to create a ClassSession'
    pending 'updates an existing ClassSession with Google Calendar event data'
    pending 'handles recurring events'
    pending 'handles cancelled events'
  end

  describe '#effective_owner' do
    pending 'returns owner_user when set'
    pending 'falls back to teacher when owner_user is not set'
  end

  describe '#effective_owner_calendar_id' do
    pending 'returns owner_calendar.calendar_id when set'
    pending "returns 'primary' when owner_calendar is not set"
  end
end
