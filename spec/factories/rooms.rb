FactoryBot.define do
  factory :room do
    room_code { "MyString" }
    quiz { nil }
    host_user_id { 1 }
    status { 1 }
    current_question_index { 1 }
    started_at { "2025-11-03 15:33:46" }
    max_players { 1 }
  end
end
