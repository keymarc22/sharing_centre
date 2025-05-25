class StudyInterval < ApplicationRecord
  has_many :program_intervals, dependent: :destroy
  has_many :programs, through: :program_intervals

  validates :name, :study_sessions, :study_frequency, presence: true
end