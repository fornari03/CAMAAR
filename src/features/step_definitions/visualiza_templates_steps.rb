# =========================================
# Contexto (Dado)
# =========================================

Dado('que estou logado') do
  step "que eu estou logado como Administrador"
end

Dado('que existe um template criado com o campo {string} preenchido com {string}, e o campo {string} preenchido com {string}, e o campo {string} preenchido com {string}') do |field1, value1, field2, value2, field3, value3|
  title = "#{value1} - #{value2} - #{value3}"
  criador = Usuario.first || Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true)
  Template.create!(titulo: title, criador: criador, hidden: false)
end

Dado('que não existe nenhum template criado') do
  Template.destroy_all
end

# =========================================
# Verificações (Então)
# =========================================

Então('devo ver um cartão da disciplina contendo: {string},{string},{string}') do |val1, val2, val3|
  expect(page).to have_content(val1)
  expect(page).to have_content(val2)
  expect(page).to have_content(val3)
end

Então('devo visualizar a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end