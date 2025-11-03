FactoryBot.define do
  factory :answer do
    room { nil }
    player { nil }
    question { nil }
    answer { "MyString" }
    time_taken { 1.5 }
    correct { false }
  end
end
