FactoryBot.define do
  factory :card do
    recipient_name { 'Joe' }
    recipient_email { 'dwef@dwef.fr'}
    title { 'Great card' }
    association :owner, factory: :user
    path { 'R4nD0mpAtH' }
  end
end