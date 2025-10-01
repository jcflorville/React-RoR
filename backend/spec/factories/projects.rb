FactoryBot.define do
  factory :project do
    name { Faker::App.name }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    status { :active }
    priority { :medium }
    start_date { 1.week.ago }
    end_date { 2.months.from_now }
    association :user

    trait :draft do
      status { :draft }
    end

    trait :completed do
      status { :completed }
    end

    trait :archived do
      status { :archived }
    end

    trait :high_priority do
      priority { :high }
    end

    trait :urgent do
      priority { :urgent }
    end

    trait :overdue do
      end_date { 1.week.ago }
    end

    trait :with_categories do
      after(:create) do |project|
        project.categories = create_list(:category, 2)
      end
    end

    trait :with_tasks do
      after(:create) do |project|
        create_list(:task, 3, project: project)
      end
    end
  end
end
