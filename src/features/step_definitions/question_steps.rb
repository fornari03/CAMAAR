# =========================================
# Verificações (Então)
# =========================================

Então('eu devo ver um formulário de nova questão') do
  expect(page).to have_selector('.question-form')
end

Então('o número total de questões deve ser {int}') do |count|
  expect(TemplateQuestion.count).to eq(count)
end
