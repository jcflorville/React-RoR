FactoryBot.define do
  factory :comment do
    content { Faker::Lorem.paragraph(sentence_count: 2) }
    association :task
    association :user

    trait :edited do
      edited_at { 1.hour.ago }
    end

    trait :recent do
      created_at { 1.hour.ago }
    end

    trait :old do
      created_at { 1.week.ago }
    end
  end
end
