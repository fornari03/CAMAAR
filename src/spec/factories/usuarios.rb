FactoryBot.define do
  factory :usuario do
    sequence(:nome) { |n| "Usuário #{n}" }
    sequence(:email) { |n| "usuario#{n}@camaar.com" }
    sequence(:matricula) { |n| "2020#{n.to_s.rjust(5, '0')}" }
    sequence(:usuario) { |n| "user#{n}" }
    password { "password" }
    password_confirmation { "password" }
    ocupacao { :discente } # Default to discente
    status { true }

    trait :admin do
      ocupacao { :admin }
    end

    trait :docente do
      ocupacao { :docente }
    end
  end
end
