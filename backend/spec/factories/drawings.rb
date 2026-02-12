FactoryBot.define do
  factory :drawing do
    association :user
    sequence(:title) { |n| "Drawing #{n}" }
    canvas_data do
      {
        version: '5.3.0',
        objects: [],
        background: '#ffffff'
      }
    end
    lock_version { 0 }
  end
end
