# =========================================
# Contexto (Dado)
# =========================================

# Step simplificado para login.
Dado('que estou logado') do
  step "que eu estou logado como Administrador"
end

# Cria template com dados específicos.
#
# Argumentos:
#   - field1, value1, ...: Pares campo/valor (ignora campo, usa valores para título).
#
# Efeitos Colaterais:
#   - Cria Template com título concatenado e hidden=false.
Dado('que existe um template criado com o campo {string} preenchido com {string}, e o campo {string} preenchido com {string}, e o campo {string} preenchido com {string}') do |field1, value1, field2, value2, field3, value3|
  title = "#{value1} - #{value2} - #{value3}"
  criador = Usuario.first || Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true)
  Template.create!(titulo: title, criador: criador, hidden: false)
end

# Limpa templates.
#
# Efeitos Colaterais:
#   - Destroy all templates.
Dado('que não existe nenhum template criado') do
  Template.destroy_all
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica conteúdo do cartão/template.
#
# Argumentos:
#   - val1, val2, val3 (String): Valores esperados.
Então('devo ver um cartão da disciplina contendo: {string},{string},{string}') do |val1, val2, val3|
  expect(page).to have_content(val1)
  expect(page).to have_content(val2)
  expect(page).to have_content(val3)
end

# Verifica mensagem geral.
#
# Argumentos:
#   - mensagem (String): Mensagem esperada.
Então('devo visualizar a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end