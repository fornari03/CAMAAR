Dado('que eu estou na página de login') do
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('existe um usuário {string} cadastrado com email {string}, matrícula {string} e senha {string}') do |string, string2, string3, string4|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('existe um usuário {string} cadastrado com email {string}, matrícula {string}, senha {string} e com permissão de administrador') do |string, string2, string3, string4|
  pending # Write code here that turns the phrase above into concrete actions
end

Quando('eu preencho o campo {string} com {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Quando('eu clico no botão {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('eu devo ser redirecionado para a página inicial') do
  pending # Write code here that turns the phrase above into concrete actions
end

Então('eu devo ver a mensagem {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('eu NÃO devo ver a opção {string} no menu lateral') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('eu devo ver a opção {string} no menu lateral') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('eu devo permanecer na página de login') do
  pending # Write code here that turns the phrase above into concrete actions
end


Dado('que existe um usuário {string} \({int}) pré-cadastrado via SIGAA, mas com status {string}') do |string, int, string2|
# Dado('que existe um usuário {string} \({float}) pré-cadastrado via SIGAA, mas com status {string}') do |string, float, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('eu estou na página de login') do
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('eu estou na página de {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Quando('eu preencho {string} com {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('o status do usuário {string} deve continuar {string}') do |email_ou_matricula, status|
  usuario = Usuario.find_by(email: email_ou_matricula) || Usuario.find_by(matricula: email_ou_matricula)
  expect(usuario.status).to eq(status)
end

# Pending steps added
Dado('que eu sou um {string} não autenticado') do |role|
  pending "Authentication logic for unauthenticated #{role} not implemented"
end

Quando('eu tento acessar a funcionalidade de criação \(clicar no botão {string})') do |button_text|
  pending "Access control testing logic not implemented"
end