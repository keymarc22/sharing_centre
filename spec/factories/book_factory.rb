FactoryBot.define do
  factory :book do
    name      { 'English A1' }
    language  { 'en' }
    keywords  { 'english,a1,basic,grammar' }
    lesson
  end

  factory :book_list do
    name { 'Pending lessons' }
    student

    trait :with_books do
      after(:create) do |list|
        list.books < create(:book)
      end
    end
  end
end