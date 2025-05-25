require 'rails_helper'

RSpec.describe Book, type: :model do
  let(:lesson) { Lesson.create!(name: "Lección", language: StudyDataConcern::LANGUAGES.first) }
  let(:lesson_topic) { LessonTopic.create!(lesson: lesson, name: "Tema", category: StudyDataConcern::TOPIC_CATEGORIES.first) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      book = Book.new(name: "Libro", language: StudyDataConcern::LANGUAGES.first, lesson: lesson, lesson_topic: lesson_topic)
      expect(book).to be_valid
    end

    it 'is invalid without a name' do
      book = Book.new(language: StudyDataConcern::LANGUAGES.first)
      expect(book).not_to be_valid
      expect(book.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a language' do
      book = Book.new(name: "Libro")
      expect(book).not_to be_valid
      expect(book.errors[:language]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'can belong to a lesson' do
      book = Book.new(name: "Libro", language: StudyDataConcern::LANGUAGES.first, lesson: lesson)
      expect(book.lesson).to eq(lesson)
    end

    it 'can belong to a lesson_topic' do
      book = Book.new(name: "Libro", language: StudyDataConcern::LANGUAGES.first, lesson_topic: lesson_topic)
      expect(book.lesson_topic).to eq(lesson_topic)
    end
  end
end