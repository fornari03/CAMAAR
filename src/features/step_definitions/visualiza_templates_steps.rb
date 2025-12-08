Dado('que estou logado') do
  step 'que eu estou logado como Administrador'
end

Dado(
  'existe um template criado com o campo nome_da_matéria igual a {string}, ' \
  'e o campo semestre igual a {string}, ' \
  'e o campo professor igual a {string}'
) do |nome, semestre, professor|
  # TODO: implementar criação do template com esses dados.
  # Exemplo (ajuste aos atributos reais do modelo):
  #
  # criador = Usuario.find_by(usuario: 'admin') || Usuario.create!(
  #   nome: 'Admin',
  #   email: 'admin@test.com',
  #   matricula: '123456',
  #   usuario: 'admin',
  #   password: 'password',
  #   ocupacao: :admin,
  #   status: true
  # )
  #
  # Template.create!(
  #   titulo: nome,
  #   participantes: professor,
  #   name: "#{nome} - #{semestre} - #{professor}",
  #   id_criador: criador.id
  # )
  pending 'Implementar criação do template com nome, semestre e professor'
end

Então('devo ver um cartão da disciplina contendo: {string}, {string}, {string}') do |nome, semestre, professor|
  expect(page).to have_content(nome)
  expect(page).to have_content(semestre)
  expect(page).to have_content(professor)
end

Dado('que não existe nenhum template criado') do
  Template.destroy_all
end

Então('devo visualizar a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
