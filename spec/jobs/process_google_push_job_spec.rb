require 'rails_helper'

RSpec.describe ProcessGooglePushJob, type: :job do
  describe '#perform' do
    pending 'processes sync notification'
    pending 'processes exists notification and triggers sync'
    pending 'processes not_exists notification and cleans up'
    pending 'handles missing watch channel gracefully'
  end
end
