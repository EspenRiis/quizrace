FactoryBot.define do
  factory :quiz do
    name { "MyString" }
    questions_count { 1 }
    created_by_id { 1 }
  end
end
