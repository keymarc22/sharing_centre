require 'rails_helper'

RSpec.describe Lesson, type: :model do
  let(:valid_attributes) do
    {
      name: "Lección 1",
      language: StudyDataConcern::LANGUAGES.first
    }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      lesson = Lesson.new(valid_attributes)
      expect(lesson).to be_valid
    end

    it 'is invalid without a name' do
      lesson = Lesson.new(valid_attributes.merge(name: nil))
      expect(lesson).not_to be_valid
      expect(lesson.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a language' do
      lesson = Lesson.new(valid_attributes.merge(language: nil))
      expect(lesson).not_to be_valid
      expect(lesson.errors[:language]).to include("can't be blank")
    end

    it 'is invalid with a language not in the allowed list' do
      lesson = Lesson.new(valid_attributes.merge(language: "xx"))
      expect(lesson).not_to be_valid
      expect(lesson.errors[:language]).to include("is not included in the list")
    end
  end

  describe 'associations' do
    it 'has many topics' do
      lesson = Lesson.create!(valid_attributes)
      topic1 = LessonTopic.create!(lesson: lesson, name: "Tema 1", category: StudyDataConcern::TOPIC_CATEGORIES.first)
      topic2 = LessonTopic.create!(lesson: lesson, name: "Tema 2", category: StudyDataConcern::TOPIC_CATEGORIES.first)
      expect(lesson.topics).to include(topic1, topic2)
    end
  end
end