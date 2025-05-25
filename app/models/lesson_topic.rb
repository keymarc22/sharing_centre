class LessonTopic < ApplicationRecord
  belongs_to :lesson

  has_many :personalized_program_topics, dependent: :destroy
  has_many :personalized_programs, through: :personalized_program_topics

  validates :name, :category, presence: true
  validates_inclusion_of :category, in: StudyDataConcern::TOPIC_CATEGORIES
end