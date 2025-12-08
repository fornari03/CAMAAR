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

Dado(
  'existe um usuário {string} cadastrado com email {string}, matrícula {string}, senha {string} e com permissão de administrador'
) do |nome, email, matricula, senha|
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
  expect(page).to have_current_path("/")
end

Então('eu devo ser redirecionado para a página de administrador') do 
  expect(page).to have_current_path('/admin')
end

Então('eu devo ver a mensagem {string}') do |mensagem|
  texto = mensagem.sub(/\.$/, '') 
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
  # garante que continuamos na página de login
  expect(page).to have_current_path("/login")
end

# ------------- Steps pendentes (ainda OK ficar assim) -------------

Dado('que existe um usuário {string} \({int}) pré-cadastrado via SIGAA, mas com status {string}') do |string, int, string2|
  pending # implementar caso de usuário pré-cadastrado pendente
end

# este step é redundante com "que eu estou na página de login",
# mas mantive pra você decidir depois se quer unificar
Dado('eu estou na página de login') do
  visit "/login"
end

Dado('eu estou na página de {string}') do |string|
  pending # implementar navegação genérica por nome de página, se precisar
end

Quando('eu preencho {string} com {string}') do |string, string2|
  pending # implementar se for usar esses steps nos cenários de esqueci senha
end

Então('o status do usuário {string} deve continuar {string}') do |email_ou_matricula, status|
  usuario = Usuario.find_by(email: email_ou_matricula) || Usuario.find_by(matricula: email_ou_matricula)
  expect(usuario.status).to eq(status)
end

Dado('que eu sou um {string} não autenticado') do |role|
  pending "Authentication logic for unauthenticated #{role} not implemented"
end

Quando('eu tento acessar a funcionalidade de criação \(clicar no botão {string})') do |button_text|
  pending "Access control testing logic not implemented"
end
