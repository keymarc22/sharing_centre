class ProgramInterval < ApplicationRecord
  belongs_to :study_interval
  belongs_to :program
end