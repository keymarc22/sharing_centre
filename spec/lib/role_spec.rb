require 'rails_helper'

RSpec.describe Role, type: :lib do
  describe '.can?' do
    it 'returns true for superadmin regardless of action' do
      expect(Role.can?('superadmin', :anything)).to be true
    end

    it 'returns false for an unknown role' do
      expect(Role.can?('nonexistent_role', :manage)).to be false
    end
  end
end