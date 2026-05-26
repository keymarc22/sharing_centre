require 'rails_helper'

RSpec.describe User, type: :model do
  subject { described_class.new(name: "Test User", email: "test@example.com", country_code: "US", password: "password123") }

  context 'validations' do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "is invalid without an email" do
      subject.email = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it "is invalid without a country_code" do
      subject.country_code = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:country_code]).to include("can't be blank")
    end

    it "is invalid without a password" do
      subject.password = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:password]).to include("can't be blank")
    end
  end

  context 'ability' do
    it 'works' do
      subject.role = 'admin'

      expect(subject.can?(:lessons)).to be true
      expect(subject.can?(:lessons, :read)).to be true
      expect(subject.can?(:users)).to be false

      expect(subject.admin?).to be true

      subject.role = 'student'

      expect(subject.can?(:lessons)).to be false # because :manage is not allowed
      expect(subject.can?(:lessons, :show)).to be true
    end
  end
end

RSpec.describe Student, type: :model do
  context 'store_accessor' do
    let(:student) do
      described_class.new(
        name: "Student User",
        email: "student@example.com",
        country_code: "US",
        password: "password123",
        custom_data: {}
      )
    end

    it "allows reading and writing :birthday" do
      student.birthday = "2000-01-01"
      expect(student.birthday).to eq("2000-01-01")
    end

    it "allows reading and writing :profession" do
      student.profession = "Engineer"
      expect(student.profession).to eq("Engineer")
    end

    it "allows reading and writing :work_position" do
      student.work_position = "Manager"
      expect(student.work_position).to eq("Manager")
    end

    it "allows reading and writing :workplace" do
      student.workplace = "Tech Corp"
      expect(student.workplace).to eq("Tech Corp")
    end

    it "allows reading and writing :learning_needs" do
      student.learning_needs = "Improve English"
      expect(student.learning_needs).to eq("Improve English")
    end

    it "allows reading and writing :current_language_level" do
      student.current_language_level = "B2"
      expect(student.current_language_level).to eq("B2")
    end

    it "persists custom_data fields after save and reload" do
      student.birthday = "1995-05-05"
      student.profession = "Teacher"
      student.save!
      reloaded = described_class.find(student.id)
      expect(reloaded.birthday).to eq("1995-05-05")
      expect(reloaded.profession).to eq("Teacher")
    end
  end
end

RSpec.describe User, type: :model do
  before do
    stub_const('ROLES', ['student', 'admin'])
    stub_const('Role::List', ['student', 'admin'])

    stub_const('DummyUser', Class.new do
      include ActiveModel::Model
      include RolableConcern
      attr_accessor :role
    end)
  end

  let(:instance) { DummyUser.new(role: role) }
  let(:role) { 'student' }

  describe 'validations' do
    it 'is invalid without a role' do
      obj = DummyUser.new(role: nil)
      expect(obj).not_to be_valid
      expect(obj.errors[:role]).to include("can't be blank")
    end

    it 'is invalid with a role not in Role::List' do
      obj = DummyUser.new(role: 'unknown')
      expect(obj).not_to be_valid
      expect(obj.errors[:role]).to include("is not included in the list")
    end
  end

  describe '#can?' do
    it 'delegates to Role.can? with the instance role and given action' do
      expect(Role).to receive(:can?).with('student', :lessons, :show).and_return(true)
      expect(instance.can?(:lessons, :show)).to be true
    end
  end

  describe 'role predicate methods' do
    it 'defines predicate for each role in ROLES' do
      expect(instance).to respond_to(:student?)
      expect(instance).to respond_to(:admin?)
    end

    it 'returns true for matching predicate and false otherwise' do
      expect(instance.student?).to be true
      expect(instance.admin?).to be false
    end
  end
end

RSpec.describe User, type: :model do
  describe '.from_omniauth' do
    let(:auth) do
      double('OmniAuth::AuthHash',
        provider: 'google_oauth2',
        uid: '12345',
        info: double(name: 'Test User', email: 'test@example.com', image: 'https://example.com/avatar.jpg', country_code: 'US'),
        credentials: double(token: 'access_token_123', refresh_token: 'refresh_token_123', expires_at: (Time.current + 1.hour).to_i)
      )
    end

    context 'when user does not exist' do
      it 'creates a new user' do
        expect {
          User.from_omniauth(auth)
        }.to change(User, :count).by(1)
      end

      it 'saves google tokens' do
        user = User.from_omniauth(auth)

        expect(user.google_access_token).to eq('access_token_123')
        expect(user.google_refresh_token).to eq('refresh_token_123')
        expect(user.google_token_expires_at).to be_present
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).to eq('12345')
      end

      it 'sets default role to student' do
        user = User.from_omniauth(auth)
        expect(user.role).to eq('student')
      end
    end

    context 'when user already exists' do
      let!(:existing_user) { create(:user, provider: 'google_oauth2', uid: '12345') }

      it 'updates existing user' do
        expect {
          User.from_omniauth(auth)
        }.not_to change(User, :count)
      end

      it 'updates google tokens on re-login' do
        User.from_omniauth(auth)

        existing_user.reload
        expect(existing_user.google_access_token).to eq('access_token_123')
        expect(existing_user.google_refresh_token).to eq('refresh_token_123')
      end
    end

    context 'when email is missing' do
      let(:auth_without_email) do
        double('OmniAuth::AuthHash',
          provider: 'google_oauth2',
          uid: '12345',
          info: double(name: 'Test', email: nil, image: nil, country_code: nil),
          credentials: nil
        )
      end

      it 'returns nil' do
        result = User.from_omniauth(auth_without_email)
        expect(result).to be_nil
      end
    end
  end

  describe '#google_connected?' do
    context 'when user has google oauth' do
      let(:user) { create(:user, :with_google_oauth) }

      it 'returns true' do
        expect(user.google_connected?).to be true
      end
    end

    context 'when user does not have google oauth' do
      let(:user) { create(:user) }

      it 'returns false' do
        expect(user.google_connected?).to be false
      end
    end

    context 'when user has provider but no token' do
      let(:user) { create(:user, provider: 'google_oauth2', google_access_token: nil) }

      it 'returns false' do
        expect(user.google_connected?).to be false
      end
    end
  end

  describe '#google_token_expired?' do
    context 'when token has expired' do
      let(:user) { create(:user, :with_google_oauth, google_token_expires_at: 1.hour.ago) }

      it 'returns true' do
        expect(user.google_token_expired?).to be true
      end
    end

    context 'when token is still valid' do
      let(:user) { create(:user, :with_google_oauth, google_token_expires_at: 1.hour.from_now) }

      it 'returns false' do
        expect(user.google_token_expired?).to be false
      end
    end

    context 'when token expiration is not set' do
      let(:user) { create(:user, google_token_expires_at: nil) }

      it 'returns false' do
        expect(user.google_token_expired?).to be false
      end
    end
  end
end