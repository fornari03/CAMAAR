Dado('que estou logado') do
  step "que eu estou logado como Administrador"
end

Dado(
  'existe um template criado com o campo nome_da_matéria igual a {string}, ' \
  'e o campo semestre igual a {string}, ' \
  'e o campo professor igual a {string}'
) do |nome, semestre, professor|
  pending
end

Então('devo ver um cartão da disciplina contendo: {string}, {string}, {string}') do |nome, semestre, professor|
  pending
Então('devo ver um cartão da disciplina contendo: {string},{string},{string}') do |val1, val2, val3|
  expect(page).to have_content(val1)
  expect(page).to have_content(val2)
  expect(page).to have_content(val3)
end

Dado('que não existe nenhum template criado') do
  Template.destroy_all
end

Então('devo visualizar a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end