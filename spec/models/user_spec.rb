require 'rails_helper'

RSpec.describe User, type: :model do
  subject { described_class.new(name: "Test User", email: "test@example.com", country_code: "US", password: "password123") }

  context 'validations' do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "is invalid without an email" do
      subject.email = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it "is invalid without a country_code" do
      subject.country_code = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:country_code]).to include("can't be blank")
    end

    it "is invalid without a password" do
      subject.password = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:password]).to include("can't be blank")
    end
  end
end

RSpec.describe Student, type: :model do
  context 'store_accessor' do
    let(:student) do
      described_class.new(
        name: "Student User",
        email: "student@example.com",
        country_code: "US",
        password: "password123",
        custom_data: {}
      )
    end

    it "allows reading and writing :birthday" do
      student.birthday = "2000-01-01"
      expect(student.birthday).to eq("2000-01-01")
    end

    it "allows reading and writing :profession" do
      student.profession = "Engineer"
      expect(student.profession).to eq("Engineer")
    end

    it "allows reading and writing :work_position" do
      student.work_position = "Manager"
      expect(student.work_position).to eq("Manager")
    end

    it "allows reading and writing :workplace" do
      student.workplace = "Tech Corp"
      expect(student.workplace).to eq("Tech Corp")
    end

    it "allows reading and writing :learning_needs" do
      student.learning_needs = "Improve English"
      expect(student.learning_needs).to eq("Improve English")
    end

    it "allows reading and writing :current_language_level" do
      student.current_language_level = "B2"
      expect(student.current_language_level).to eq("B2")
    end

    it "persists custom_data fields after save and reload" do
      student.birthday = "1995-05-05"
      student.profession = "Teacher"
      student.save!
      reloaded = described_class.find(student.id)
      expect(reloaded.birthday).to eq("1995-05-05")
      expect(reloaded.profession).to eq("Teacher")
    end
  end
end
