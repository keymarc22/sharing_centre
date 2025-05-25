require 'rails_helper'

RSpec.describe PersonalizedProgram, type: :model do
  let(:student) { create(:student) }
  let(:personalized_program) { create(:personalized_program, student: student) }
  let(:lesson) { create(:lesson, name: "Lección 1") }
  let(:topic1) { create(:lesson_topic, lesson:, name: "Tema 1", category: StudyDataConcern::TOPIC_CATEGORIES.first) }
  let(:topic2) { create(:lesson_topic, lesson:, name: "Tema 2", category: StudyDataConcern::TOPIC_CATEGORIES.first) }

  describe 'associations' do
    it 'belongs to student' do
      expect(personalized_program.student).to eq(student)
    end

    it 'has many personalized_program_topics' do
      ppt = PersonalizedProgramTopic.create!(personalized_program: personalized_program, lesson_topic: topic1)
      expect(personalized_program.personalized_program_topics).to include(ppt)
    end

    it 'has many topics through personalized_program_topics' do
      ppt1 = PersonalizedProgramTopic.create!(personalized_program: personalized_program, lesson_topic: topic1)
      ppt2 = PersonalizedProgramTopic.create!(personalized_program: personalized_program, lesson_topic: topic2)
      expect(personalized_program.topics).to include(topic1, topic2)
    end
  end
end