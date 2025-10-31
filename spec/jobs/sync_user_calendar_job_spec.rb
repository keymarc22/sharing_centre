require 'rails_helper'

RSpec.describe SyncUserCalendarJob, type: :job do
  describe '#perform' do
    pending 'syncs events from Google Calendar'
    pending 'updates sync token after successful sync'
    pending 'handles sync token invalid error with retry'
    pending 'creates ClassSession records from Google events'
  end
end
