FactoryBot.define do
  factory :lesson do
    name           { 'Present simple' }
    language       { 'es' }
    language_level { 'A1' }
  end

  factory :lesson_topic do
    lesson
    name     { 'Verb TO BE' }
    category { 'reading' }
  end
end