class Program < ApplicationRecord
  include PriceableConcern

  has_many :student_programs
  has_many :students, through: :student_programs

  has_many :program_intervals, dependent: :destroy
  has_many :study_intervals, through: :program_intervals

  validates :name, :description, :price, :status, :language, presence: true
  validates :language, inclusion: { in: StudyDataConcern::LANGUAGES }

  enum :status, %i[published archived trashed]

  def subscribe!(student:, study_interval:)

  end
end
