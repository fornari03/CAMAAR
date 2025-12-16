# =========================================
# Contexto (Dado)
# =========================================

# Prepara um usuário importado com estado específico.
#
# Argumentos:
#   - email (String): Email do usuário.
#   - status_desc (String): "ativo" ou outro valor.
#
# Efeitos Colaterais:
#   - Cria registro de Usuario.
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

# Prepara um usuário ativo.
#
# Argumentos:
#   - email (String): Email.
#
# Efeitos Colaterais:
#   - Cria registro de Usuario.
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

# Gera link de definição de senha.
#
# Argumentos:
#   - email (String): Email.
#
# Efeitos Colaterais:
#   - Gera token e define @link_definicao.
Dado('um link de definição de senha válido foi enviado para {string}') do |email|
  user = Usuario.find_by!(email: email)
  token = user.signed_id(purpose: :definir_senha, expires_in: 24.hours)
  @link_definicao = "/definir_senha?token=#{token}"
end

# =========================================
# Ações (Quando)
# =========================================

# Acessa página via link válido armazenado.
#
# Argumentos:
#   - page_name (String): Nome da página (não usado na lógica).
#
# Efeitos Colaterais:
#   - Visita URL.
Quando('eu acesso a página {string} usando o link válido') do |page_name|
  visit @link_definicao
end

# Acessa página usando link antigo (sem expiração explícita no step, mas gera novo token).
#
# Argumentos:
#   - page_name (String): Nome da página.
#
# Efeitos Colaterais:
#   - Visita URL.
Quando('eu acesso a página {string} usando o link antigo') do |page_name|
  user = @user
  token = user.signed_id(purpose: :definir_senha)
  visit "/definir_senha?token=#{token}"
end

# Deixa campo em branco.
#
# Argumentos:
#   - campo (String): Nome do campo.
#
# Efeitos Colaterais:
#   - Preenche input com string vazia.
Quando('eu deixo o campo {string} em branco') do |campo|
  if campo == 'Email'
    fill_in 'Usuário', with: ""
  else
    fill_in campo, with: ""
  end
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica redirecionamento.
#
# Argumentos:
#   - page_name (String): Nome da página destino.
#
# Retorno:
#   - (Boolean): Asserção de caminho.
Então('eu devo ser redirecionado para a página de {string}') do |page_name|
  expect(page).to have_current_path(path_to(page_name))
end

# Verifica status do usuário no banco.
#
# Argumentos:
#   - email (String): Email.
#   - status_esperado (String): "ativo" ou outro.
#
# Retorno:
#   - (Boolean): Asserção de status.
Então('o status do usuário {string} no sistema deve ser {string}') do |email, status_esperado|
  user = Usuario.find_by(email: email)
  user.reload 
  
  if status_esperado == "ativo"
    expect(user.status).to be_truthy
  else
    expect(user.status).to be_falsey
  end
end