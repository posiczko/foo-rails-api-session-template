FactoryBot.define do
  factory :user do
    sequence(:username) { FFaker::Internet.email }
    sequence(:first_name) { FFaker::Name.first_name }
    sequence(:last_name) { FFaker::Name.last_name }
    password_digest { BCrypt::Password.create('secret') }
  end
end
