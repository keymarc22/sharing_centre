class PersonalizedProgramTopic < ApplicationRecord
  belongs_to :lesson_topic
  belongs_to :personalized_program
end