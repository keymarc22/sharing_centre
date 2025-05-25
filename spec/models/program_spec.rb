require 'rails_helper'

RSpec.describe Program, type: :model do
  let(:valid_attributes) do
    {
      name: "Programa 1",
      description: "Descripción",
      price: 1000,
      status: "published",
      language: StudyDataConcern::LANGUAGES.first
    }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      program = Program.new(valid_attributes)
      expect(program).to be_valid
    end

    it 'is invalid without a name' do
      program = Program.new(valid_attributes.merge(name: nil))
      expect(program).not_to be_valid
      expect(program.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a description' do
      program = Program.new(valid_attributes.merge(description: nil))
      expect(program).not_to be_valid
      expect(program.errors[:description]).to include("can't be blank")
    end

    it 'is invalid without a price' do
      program = Program.new(valid_attributes.merge(price: nil))
      expect(program).not_to be_valid
      expect(program.errors[:price]).to include("must be greater than 0")
    end

    it 'is invalid without a status' do
      program = Program.new(valid_attributes.merge(status: nil))
      expect(program).not_to be_valid
      expect(program.errors[:status]).to include("can't be blank")
    end

    it 'is invalid without a language' do
      program = Program.new(valid_attributes.merge(language: nil))
      expect(program).not_to be_valid
      expect(program.errors[:language]).to include("can't be blank")
    end

    it 'is invalid with a language not in the allowed list' do
      program = Program.new(valid_attributes.merge(language: "xx"))
      expect(program).not_to be_valid
      expect(program.errors[:language]).to include("is not included in the list")
    end
  end

  describe 'enums' do
    it 'accepts valid statuses' do
      %w[published archived trashed].each do |status|
        program = Program.new(valid_attributes.merge(status: status))
        expect(program).to be_valid
      end
    end

    it 'is invalid with an unknown status' do
      expect {
        Program.new(valid_attributes.merge(status: "unknown"))
      }.to raise_error(ArgumentError)
    end
  end
end