FactoryBot.define do
  factory :player do
    room { nil }
    username { "MyString" }
    avatar { "MyString" }
    score { 1 }
    position { 1 }
    uuid { "MyString" }
    player_secret { "MyString" }
  end
end
