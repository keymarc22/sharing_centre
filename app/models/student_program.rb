class StudentProgram < ApplicationRecord
  include PriceableConcern

  belongs_to :program
  belongs_to :student
  belongs_to :study_interval

  validates :student, :price, :study_sessions, :study_frequency, :status, :language, :start_date, presence: true
  validates :language, inclusion: { in: StudyDataConcern::LANGUAGES }
  validates :study_frequency, inclusion: { in: StudyDataConcern::STUDY_FREQUENCY }
  validates :student_id, uniqueness: { scope: :status,
                          message: "already has an active program.",
                          if: :active?
                        }

  enum :status, %i[active finished]
end