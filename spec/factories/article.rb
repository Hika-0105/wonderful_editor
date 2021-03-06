FactoryBot.define do
  factory :article do
    title { Faker::Lorem.word }
    body { Faker::Lorem.sentence }
    user
    status { :draft }
  end

  trait :status_published do
    status { :published }
  end
end
