FactoryBot.define do
  factory :category do
    name { "#{Faker::ProgrammingLanguage.name.first(2).upcase}#{Faker::Lorem.word.capitalize}" }
    color { Faker::Color.hex_color }
    description { Faker::Lorem.sentence }

    trait :frontend do
      name { 'Frontend' }
      color { '#3B82F6' }
      description { 'Desenvolvimento de interfaces' }
    end

    trait :backend do
      name { 'Backend' }
      color { '#EF4444' }
      description { 'APIs e lógica de negócio' }
    end

    trait :devops do
      name { 'DevOps' }
      color { '#10B981' }
      description { 'Infraestrutura e deploy' }
    end
  end
end
