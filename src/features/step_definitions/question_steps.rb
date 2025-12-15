# =========================================
# Verificações (Então)
# =========================================

# Verifica presença do formulário de nova questão.
#
# Efeitos Colaterais:
#   - Asserção de seletor CSS.
Então('eu devo ver um formulário de nova questão') do
  expect(page).to have_selector('.question-form')
end

# Verifica contagem de questões de template.
#
# Argumentos:
#   - count (Integer): Quantidade esperada.
Então('o número total de questões deve ser {int}') do |count|
  expect(TemplateQuestion.count).to eq(count)
end
