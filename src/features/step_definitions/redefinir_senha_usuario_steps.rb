Dado('que o usuário {string} está cadastrado e ativo no sistema') do |email|
  Usuario.create!(
    nome: "Usuário Teste",
    email: email,
    usuario: "2023#{rand(1000..9999)}",
    matricula: "2023#{rand(1000..9999)}",
    password: "Password123!",
    ocupacao: :discente,
    status: true
  )
end

Então('eu devo permanecer na página de {string}') do |page_name|
  expect(page).to have_current_path(path_to(page_name))
end

Então('nenhum e-mail deve ser enviado') do
  expect(ActionMailer::Base.deliveries.count).to eq(0)
end

Dado('que o e-mail {string} não está cadastrado no sistema') do |email|
  Usuario.where(email: email).destroy_all
end

Dado('que o usuário {string} solicitou um link de redefinição válido') do |email|
  user = Usuario.find_by(email: email) || Usuario.create!(
    nome: "Usuário Teste",
    email: email,
    usuario: "2023#{rand(1000..9999)}",
    matricula: "2023#{rand(1000..9999)}",
    password: "PasswordAntiga123!",
    ocupacao: :discente,
    status: true
  )

  token = user.signed_id(purpose: :redefinir_senha, expires_in: 15.minutes)
  
  @link_definicao = "/redefinir_senha/edit?token=#{token}"
end

Então('o usuário {string} deve conseguir logar com a senha {string}') do |email, nova_senha|
  visit '/login'
  fill_in 'Email', with: email
  fill_in 'Senha', with: nova_senha
  click_on 'Entrar'
  expect(page).to have_no_content("Entrar")
end

Dado('que o usuário {string} está cadastrado no sistema com o status {string}') do |email, status_desc|
  is_ativo = (status_desc.downcase == 'ativo')
  
  Usuario.create!(
    nome: "Usuário Status",
    email: email,
    usuario: "2023#{rand(1000..9999)}",
    matricula: "2023#{rand(1000..9999)}",
    password: "Password123!",
    ocupacao: :discente,
    status: is_ativo
  )
end