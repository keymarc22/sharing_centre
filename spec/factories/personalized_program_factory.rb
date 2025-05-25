FactoryBot.define do
  factory :personalized_program do
    student

    trait :with_topics do
      after(:create) do |personalized_program|
        create(:personalized_program_topic, personalized_program:)
      end
    end
  end

  factory :personalized_program_topic do
    lesson_topic
    personalized_program
  end
end