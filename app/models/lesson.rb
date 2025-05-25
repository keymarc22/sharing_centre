class Lesson < ApplicationRecord
  has_many :topics, class_name: 'LessonTopic'

  validates :name, :language, presence: true
  validates_inclusion_of :language, in: StudyDataConcern::LANGUAGES
end
