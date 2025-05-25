class PersonalizedProgram < ApplicationRecord
  belongs_to :student

  has_many :personalized_program_topics, dependent: :destroy
  has_many :topics, through: :personalized_program_topics, source: :lesson_topic
end