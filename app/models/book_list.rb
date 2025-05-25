class BookList < ApplicationRecord
  belongs_to :student

  has_many :student_book_lists, dependent: :destroy
  has_many :books, through: :student_book_lists

  validates :name, presence: true
  validates :student_id, uniqueness: { scope: :name }
end