FactoryBot.define do
  factory :message do
    content { 'helloooo' }
    media { nil }
    association :user
    name { nil }
    association :card
  end
end
