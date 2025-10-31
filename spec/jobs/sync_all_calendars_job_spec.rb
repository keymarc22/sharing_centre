require 'rails_helper'

RSpec.describe SyncAllCalendarsJob, type: :job do
  describe '#perform' do
    pending 'enqueues SyncUserCalendarJob for all calendars'
    pending 'applies throttle delay between jobs'
    pending 'passes force_full_sync option to individual sync jobs'
  end
end
