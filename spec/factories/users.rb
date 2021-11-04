FactoryBot.define do
  factory :user do
    email { 'email@email.com' }
    name  { 'Matt' }
    password { 'password' }

    trait :with_a_card do
      after(:create) do |user|
        user.cards << create(:card, owner: user)
      end
    end
  end
end