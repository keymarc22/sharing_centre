require 'rails_helper'

RSpec.describe LessonTopic, type: :model do
  let(:lesson) { create(:lesson, name: "Lección 1") }
  let(:valid_attributes) do
    {
      lesson: lesson,
      name: "Tema 1",
      category: StudyDataConcern::TOPIC_CATEGORIES.first
    }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      topic = described_class.new(valid_attributes)
      expect(topic).to be_valid
    end

    it 'is invalid without a name' do
      topic = described_class.new(valid_attributes.merge(name: nil))
      expect(topic).not_to be_valid
      expect(topic.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a category' do
      topic = described_class.new(valid_attributes.merge(category: nil))
      expect(topic).not_to be_valid
      expect(topic.errors[:category]).to include("can't be blank")
    end

    it 'is invalid with a category not in the allowed list' do
      topic = described_class.new(valid_attributes.merge(category: "invalid"))
      expect(topic).not_to be_valid
      expect(topic.errors[:category]).to include("is not included in the list")
    end
  end

  describe 'associations' do
    it 'belongs to lesson' do
      topic = described_class.new(valid_attributes)
      expect(topic.lesson).to eq(lesson)
    end

    it 'has many personalized_program_topics' do
      topic = described_class.create!(valid_attributes)
      ppt = create(:personalized_program_topic, lesson_topic: topic)
      expect(topic.personalized_program_topics).to include(ppt)
    end

    it 'has many personalized_programs through personalized_program_topics' do
      topic = described_class.create!(valid_attributes)
      program = create(:personalized_program)
      ppt = create(:personalized_program_topic, lesson_topic: topic, personalized_program: program)
      expect(topic.personalized_programs).to include(program)
    end
  end
end