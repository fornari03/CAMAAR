Dado('que eu estou na página de login') do
  visit "/login"
end

Dado(
  'existe um usuário {string} cadastrado com email {string}, matrícula {string} e senha {string}'
) do |nome, email, matricula, senha|
  Usuario.create!(
    nome: nome,
    email: email,
    usuario: email,
    matricula: matricula,
    password: senha,
    password_confirmation: senha,
    ocupacao: 'discente',
    status: true
  )
end


Dado('existe um usuário {string} cadastrado com email {string}, matrícula {string}, senha {string} e com permissão de administrador') do |nome, email, matricula, senha|
  Usuario.create!(
    nome: nome,
    email: email,
    usuario: email,
    matricula: matricula,
    password: senha,
    password_confirmation: senha,
    ocupacao: 'admin',
    status: true
  )
end

Quando('eu preencho o campo {string} com {string}') do |campo, valor|
  fill_in campo, with: valor
end


Quando('eu clico no botão {string}') do |texto|
  click_button texto, visible: :all
end


Então('eu devo ser redirecionado para a página inicial') do
  visit "/home"
end

Então('eu devo ver a mensagem {string}') do |mensagem|
  texto = mensagem.sub(/\.$/, '') # tolera ponto final no fim
  puts "==== PAGE TEXT ===="
  puts page.text                  # debug (pode tirar depois)
  expect(page).to have_content(texto)
end



Então('eu devo ver a mensagem de Login {string}') do |mensagem|
  texto = mensagem.sub(/\.$/, '')
  expect(page).to have_content(texto)
end


Então('eu NÃO devo ver a opção {string} no menu lateral') do |texto|
  expect(page).not_to have_content(texto)
end

Então('eu devo ver a opção {string} no menu lateral') do |texto|
  expect(page).to have_content(texto)
end

Então('eu devo permanecer na página de login') do
  visit "/login"
end

Então('eu devo ser redirecionado para a página de administrador') do 
  visit "/admin"
end

Dado('que existe um usuário {string} \({int}) pré-cadastrado via SIGAA, mas com status {string}') do |string, int, string2|
# Dado('que existe um usuário {string} \({float}) pré-cadastrado via SIGAA, mas com status {string}') do |string, float, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('eu estou na página de login') do
  visit "/login"
end

Dado('eu estou na página de {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Quando('eu preencho {string} com {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('o status do usuário {string} deve continuar {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end