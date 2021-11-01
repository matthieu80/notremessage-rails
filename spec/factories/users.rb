FactoryBot.define do
  factory :user do
    email { 'email@email.com' }
    name  { 'Matt' }
    password { 'password' }
  end
end