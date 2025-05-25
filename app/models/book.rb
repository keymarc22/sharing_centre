class Book < ApplicationRecord
  belongs_to :lesson, optional: true
  belongs_to :lesson_topic, optional: true

  has_many :student_book_lists, dependent: :destroy
  has_many :book_lists, through: :student_book_lists

  validates :name, presence: true
  validates :language, presence: true
  validates_inclusion_of :language, in: StudyDataConcern::LANGUAGES
end
