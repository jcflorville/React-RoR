FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence(word_count: 4) }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    status { :todo }
    priority { :medium }
    due_date { 1.week.from_now }
    association :project
    association :user

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
      completed_at { 1.day.ago }
    end

    trait :blocked do
      status { :blocked }
    end

    trait :high_priority do
      priority { :high }
    end

    trait :urgent do
      priority { :urgent }
    end

    trait :overdue do
      due_date { 1.week.ago }
    end

    trait :with_comments do
      after(:create) do |task|
        create_list(:comment, 2, task: task)
      end
    end
  end
end
