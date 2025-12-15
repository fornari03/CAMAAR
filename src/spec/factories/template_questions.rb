FactoryBot.define do
  # Factory para TemplateQuestion.
  #
  # Gera questões de template com dados fictícios.
  factory :template_question do
    title { "MyString" }
    question_type { "MyString" }
    content { "MyText" }
    template { nil }
  end
end
