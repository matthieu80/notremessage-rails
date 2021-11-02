FactoryBot.define do
  factory :magic_link do
    user
    expired_at { (Time.now + MagicLink::EXPIRATION_TIME).to_i }
    signature { 'abcdefed '}
  end
end
