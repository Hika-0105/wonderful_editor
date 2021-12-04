FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    password { Faker::Internet.password(min_length: 8, mix_case: true, special_characters: true) }
    sequence(:email) {|n| "#{n}_#{Faker::Internet.email}" }
  end
end
