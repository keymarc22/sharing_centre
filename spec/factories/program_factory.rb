FactoryBot.define do
  factory :program do
    name        { 'Intensive' }
    description { 'My super intensive program' }
    price       { 1000 }
    language    { 'en' }

    trait :with_student_program do
      after(:create) do |program|
        create(:student_program, program:)
      end
    end

    trait :with_intervals do
      after(:create) do |program|
        program.study_intervals << create(:study_interval)
      end
    end
  end

  factory :student_program do
    student
    program
    study_interval
    price           { 1000 }
    study_sessions  { 4 }
    study_frequency { '2_per_week' }
    language        { 'en' }
    start_date      { Time.zone.today }
  end

  factory :study_interval do
    name { '4 clases semanales por 1 mes' }
    study_sessions  { 4 }
    study_frequency { '2_per_week' }
  end
end