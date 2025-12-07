FactoryBot.define do
  factory :template_question do
    title { "MyString" }
    question_type { "MyString" }
    content { "MyText" }
    template { nil }
  end
end
