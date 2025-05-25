require 'rails_helper'

RSpec.describe StudentProgram, type: :model do
  let(:program) { create(:program) }
  let(:student) { create(:student) }
  let(:study_interval) { create(:study_interval, name: "Intervalo") }
  let(:valid_attributes) do
    {
      program: program,
      student: student,
      study_interval: study_interval,
      price: 1000,
      study_sessions: 10,
      study_frequency: StudyDataConcern::STUDY_FREQUENCY.first,
      status: "active",
      language: StudyDataConcern::LANGUAGES.first,
      start_date: Date.today
    }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      sp = StudentProgram.new(valid_attributes)
      expect(sp).to be_valid
    end

    it 'is invalid without a student' do
      sp = StudentProgram.new(valid_attributes.merge(student: nil))
      expect(sp).not_to be_valid
      expect(sp.errors[:student]).to include("can't be blank")
    end

    it 'is invalid without a price' do
      sp = StudentProgram.new(valid_attributes.merge(price: nil))
      expect(sp).not_to be_valid
      expect(sp.errors[:price]).to include("must be greater than 0")
    end

    it 'is invalid without study_sessions' do
      sp = StudentProgram.new(valid_attributes.merge(study_sessions: nil))
      expect(sp).not_to be_valid
      expect(sp.errors[:study_sessions]).to include("can't be blank")
    end

    it 'is invalid without study_frequency' do
      sp = StudentProgram.new(valid_attributes.merge(study_frequency: nil))
      expect(sp).not_to be_valid
      expect(sp.errors[:study_frequency]).to include("can't be blank")
    end

    it 'is invalid with a study_frequency not in the allowed list' do
      sp = StudentProgram.new(valid_attributes.merge(study_frequency: "invalid"))
      expect(sp).not_to be_valid
      expect(sp.errors[:study_frequency]).to include("is not included in the list")
    end

    it 'is invalid without status' do
      sp = StudentProgram.new(valid_attributes.merge(status: nil))
      expect(sp).not_to be_valid
      expect(sp.errors[:status]).to include("can't be blank")
    end

    it 'is invalid without language' do
      sp = StudentProgram.new(valid_attributes.merge(language: nil))
      expect(sp).not_to be_valid
      expect(sp.errors[:language]).to include("can't be blank")
    end

    it 'is invalid with a language not in the allowed list' do
      sp = StudentProgram.new(valid_attributes.merge(language: "xx"))
      expect(sp).not_to be_valid
      expect(sp.errors[:language]).to include("is not included in the list")
    end

    it 'is invalid without start_date' do
      sp = StudentProgram.new(valid_attributes.merge(start_date: nil))
      expect(sp).not_to be_valid
      expect(sp.errors[:start_date]).to include("can't be blank")
    end

    context 'Do not allow many active programs for one student' do
      context 'uniqueness validation for student_id and status' do
        it 'does not allow two active programs for the same student' do
          StudentProgram.create!(valid_attributes)
          program = create(:program, name: "Otro", price: 1000, language: StudyDataConcern::LANGUAGES.first)
          duplicate = StudentProgram.new(valid_attributes.merge(program:))

          expect(duplicate).not_to be_valid
          expect(duplicate.errors[:student_id]).to include("already has an active program.")
        end

        it 'allows multiple finished programs for the same student' do
          StudentProgram.create!(valid_attributes.merge(status: "finished"))
          program = create(:program, name: "Otro", price: 1000, status: 'published', language: StudyDataConcern::LANGUAGES.first)

          another = StudentProgram.new(valid_attributes.merge(status: "finished", program:))
          expect(another).to be_valid
        end

        it 'allows one active and one finished program for the same student' do
          StudentProgram.create!(valid_attributes.merge(status: "active"))
          program = create(:program, name: "Otro", price: 1000, status: 'published', language: StudyDataConcern::LANGUAGES.first)

          finished = StudentProgram.new(valid_attributes.merge(status: "finished", program:))
          expect(finished).to be_valid
        end
      end
    end
  end

  describe 'enums' do
    it 'accepts valid statuses' do
      %w[active finished].each do |status|
        sp = StudentProgram.new(valid_attributes.merge(status: status))
        expect(sp).to be_valid
      end
    end

    it 'is invalid with an unknown status' do
      expect {
        StudentProgram.new(valid_attributes.merge(status: "unknown"))
      }.to raise_error(ArgumentError)
    end
  end

  describe 'associations' do
    it 'has many student_programs' do
      sp1 = StudentProgram.create!(student: student, program: program, study_interval: study_interval, price: 1000, study_sessions: 5, study_frequency: StudyDataConcern::STUDY_FREQUENCY.first, status: "active", language: StudyDataConcern::LANGUAGES.first, start_date: Date.today)
      sp2 = StudentProgram.create!(student: student, program: program, study_interval: study_interval, price: 1000, study_sessions: 5, study_frequency: StudyDataConcern::STUDY_FREQUENCY.first, status: "finished", language: StudyDataConcern::LANGUAGES.first, start_date: Date.today)
      expect(student.student_programs).to include(sp1, sp2)
    end

    it 'has many programs through student_programs' do
      program2 = Program.create!(name: "Programa 2", description: "Desc", price: 1000, status: "published", language: StudyDataConcern::LANGUAGES.first)
      StudentProgram.create!(student: student, program: program, study_interval: study_interval, price: 1000, study_sessions: 5, study_frequency: StudyDataConcern::STUDY_FREQUENCY.first, status: "active", language: StudyDataConcern::LANGUAGES.first, start_date: Date.today)
      StudentProgram.create!(student: student, program: program2, study_interval: study_interval, price: 1000, study_sessions: 5, study_frequency: StudyDataConcern::STUDY_FREQUENCY.first, status: "finished", language: StudyDataConcern::LANGUAGES.first, start_date: Date.today)
      expect(student.programs).to include(program, program2)
    end
  end
end