FactoryBot.define do
  factory :notification do
    association :user
    association :actor, factory: :user
    association :notifiable, factory: :task

    event_type { :task_assigned }
    metadata { { task_title: 'Sample Task', project_id: 1 } }
    read_at { nil }

    trait :read do
      read_at { 1.hour.ago }
    end

    trait :unread do
      read_at { nil }
    end

    trait :mention do
      event_type { :mention }
      metadata { { task_title: 'Task', comment_excerpt: 'Hey @user check this' } }
    end

    trait :task_completed do
      event_type { :task_completed }
      metadata { { task_title: 'Completed Task', project_id: 1 } }
    end

    trait :deadline_soon do
      event_type { :deadline_soon }
      metadata { { task_title: 'Urgent Task', due_date: 1.day.from_now.to_s } }
    end
  end
end
