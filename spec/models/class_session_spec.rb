require 'rails_helper'

RSpec.describe ClassSession, type: :model do
  describe 'associations' do
    it 'belongs to teacher' do
      association = described_class.reflect_on_association(:teacher)
      expect(association.macro).to eq :belongs_to
    end

    it 'belongs to student' do
      association = described_class.reflect_on_association(:student)
      expect(association.macro).to eq :belongs_to
    end

    it 'belongs to lesson' do
      association = described_class.reflect_on_association(:lesson)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'validations' do
    let(:class_session) { build(:class_session) }

    it 'is valid with valid attributes' do
      expect(class_session).to be_valid
    end

    it 'is invalid without a title' do
      class_session.title = nil
      expect(class_session).not_to be_valid
      expect(class_session.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without start_at' do
      class_session.start_at = nil
      expect(class_session).not_to be_valid
      expect(class_session.errors[:start_at]).to include("can't be blank")
    end

    it 'is invalid without end_at' do
      class_session.end_at = nil
      expect(class_session).not_to be_valid
      expect(class_session.errors[:end_at]).to include("can't be blank")
    end

    it 'is invalid when end_at is before start_at' do
      class_session.start_at = 2.hours.from_now
      class_session.end_at = 1.hour.from_now
      expect(class_session).not_to be_valid
      expect(class_session.errors[:end_at]).to include('must be after start_at')
    end

    it 'is invalid when end_at equals start_at' do
      now = 1.hour.from_now
      class_session.start_at = now
      class_session.end_at = now
      expect(class_session).not_to be_valid
      expect(class_session.errors[:end_at]).to include('must be after start_at')
    end
  end

  describe 'attributes' do
    let(:teacher) { create(:teacher) }
    let(:student) { create(:student) }

    it 'stores title and description' do
      class_session = create(:class_session, teacher: teacher, student: student, title: 'Spanish 101', description: 'Beginner Spanish')
      expect(class_session.title).to eq('Spanish 101')
      expect(class_session.description).to eq('Beginner Spanish')
    end

    it 'stores start_at and end_at' do
      start_time = 1.hour.from_now
      end_time = 2.hours.from_now
      class_session = create(:class_session, teacher: teacher, student: student, start_at: start_time, end_at: end_time)

      expect(class_session.start_at).to be_within(1.second).of(start_time)
      expect(class_session.end_at).to be_within(1.second).of(end_time)
    end

    it 'stores time zone with default UTC' do
      class_session = create(:class_session, teacher: teacher, student: student)
      expect(class_session.time_zone).to eq('UTC')
    end

    it 'stores google event id and calendar owner' do
      class_session = create(:class_session, teacher: teacher, student: student, google_event_id: 'abc123', google_calendar_owner_id: teacher.id)
      expect(class_session.google_event_id).to eq('abc123')
      expect(class_session.google_calendar_owner_id).to eq(teacher.id)
    end

    it 'stores meet link' do
      class_session = create(:class_session, teacher: teacher, student: student, meet_link: 'https://meet.google.com/abc')
      expect(class_session.meet_link).to eq('https://meet.google.com/abc')
    end
  end
end
