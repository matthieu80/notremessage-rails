FactoryBot.define do
  factory :card do
    recipient_name { 'Joe' }
    recipient_email { 'dwef@dwef.fr'}
    title { 'Great card' }
    association :owner, factory: :user
  end
end