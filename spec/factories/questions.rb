FactoryBot.define do
  factory :question do
    quiz { nil }
    sentence { "MyText" }
    question_type { 1 }
    time_limit { 1 }
    points { 1 }
    question_number { 1 }
    correct_answer { "MyString" }
    possible_answers { "" }
  end
end
