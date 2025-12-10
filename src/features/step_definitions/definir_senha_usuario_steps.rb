Dado('que o usuário {string} foi importado e está com o status {string}') do |email, status_desc|
  is_ativo = (status_desc.downcase == 'ativo')
  
  @user = Usuario.create!(
    nome: "Usuário Importado",
    email: email,
    usuario: email.split('@').first,
    matricula: "2024#{rand(1000..9999)}",
    ocupacao: :discente,
    status: is_ativo, 
    password: "SenhaTemporaria123",
    password_confirmation: "SenhaTemporaria123"
  )
end

Dado('que o usuário {string} já está ativo no sistema') do |email|
  @user = Usuario.create!(
    nome: "Usuário Já Ativo",
    email: email,
    usuario: email.split('@').first,
    matricula: "2023#{rand(1000..9999)}",
    ocupacao: :docente,
    status: true,
    password: "SenhaDefinida123",
    password_confirmation: "SenhaDefinida123"
  )
end

Dado('um link de definição de senha válido foi enviado para {string}') do |email|
  user = Usuario.find_by!(email: email)
  
  token = user.signed_id(purpose: :definir_senha, expires_in: 24.hours)
  
  @link_definicao = "/definir_senha?token=#{token}"
end

Quando('eu acesso a página {string} usando o link válido') do |page_name|
  visit @link_definicao
end



Quando('eu acesso a página {string} usando o link antigo') do |page_name|
  user = @user
  token = user.signed_id(purpose: :definir_senha)
  
  visit "/definir_senha?token=#{token}"
end

Quando('eu deixo o campo {string} em branco') do |campo|
  fill_in campo, with: ""
end

Então('eu devo ser redirecionado para a página de {string}') do |page_name|
  expect(page).to have_current_path(path_to(page_name))
end

Então('o status do usuário {string} no sistema deve ser {string}') do |email, status_esperado|
  user = Usuario.find_by(email: email)
  
  user.reload 
  
  if status_esperado == "ativo"
    expect(user.status).to be_truthy
  else
    expect(user.status).to be_falsey
  end
end

