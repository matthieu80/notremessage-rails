FactoryBot.define do
  factory :message do
    content { 'helloooo' }
    media { nil }
    association :user
    name { nil }
    association :card
    immediate_update_token { SecureRandom.uuid }
    immediate_update_token_expired_at { 2.hours.from_now }
  end
end
