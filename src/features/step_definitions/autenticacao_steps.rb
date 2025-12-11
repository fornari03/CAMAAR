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
  if campo == 'Email'
    fill_in 'Usuário', with: valor
  else
    fill_in campo, with: valor
  end
end




Então('eu devo ser redirecionado para a página inicial') do
  expect(page).to have_current_path("/")
end

Então('eu devo ser redirecionado para a página de administrador') do 
  expect(page.current_path).to eq(admin_gerenciamento_path)
end

Então('eu devo ver a mensagem de Login {string}') do |mensagem|
  texto = mensagem.sub(/\.$/, '')
  expect(page).to have_content(texto)
end

Então('eu NÃO devo ver a opção {string} no menu lateral') do |opcao|
  within('aside') do
    expect(page).not_to have_content(opcao)
  end
end

Então('eu devo ver a opção {string} no menu lateral') do |texto|
  expect(page).to have_content(texto)
end

Então('eu devo permanecer na página de login') do
  # garante que continuamos na página de login
  expect(page).to have_current_path("/login")
end

Dado('que existe um usuário {string} \({string}) pré-cadastrado via SIGAA, mas com status {string}') do |nome, matricula, status_desc|
  Usuario.create!(
    nome: nome,
    matricula: matricula,
    usuario: matricula,
    email: "#{matricula}@aluno.unb.br",
    password: "SenhaTemporaria123!",
    ocupacao: :discente,
    status: false
  )
end

# este step é redundante com "que eu estou na página de login",
# mas mantive pra você decidir depois se quer unificar
Dado('eu estou na página de login') do
  visit "/login"
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