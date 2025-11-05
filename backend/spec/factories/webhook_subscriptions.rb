FactoryBot.define do
  factory :webhook_subscription do
    association :user

    name { "Webhook #{Faker::Number.unique.number(digits: 3)}" }
    url { "https://#{Faker::Internet.domain_name}/webhook" }
    events { [ 'mention', 'task_assigned' ] }
    secret { SecureRandom.hex(32) }
    active { true }
    failure_count { 0 }

    trait :inactive do
      active { false }
    end

    trait :failed do
      failure_count { 3 }
      last_failure_at { 1.hour.ago }
    end

    trait :listening_to_all do
      events { Notification.event_types.keys }
    end

    trait :listening_to_mentions_only do
      events { [ 'mention' ] }
    end
  end
end
