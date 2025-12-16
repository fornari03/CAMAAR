# =========================================
# Contexto (Dado)
# =========================================

# Prepara um usuário ativo.
#
# Argumentos:
#   - email (String): Email.
#
# Efeitos Colaterais:
#   - Cria Usuario ativo.
Dado('que o usuário {string} está cadastrado e ativo no sistema') do |email|
  create_active_test_user(email)
end

# Garante inexistência de email.
#
# Argumentos:
#   - email (String): Email.
#
# Efeitos Colaterais:
#   - Remove usuários com esse email.
Dado('que o e-mail {string} não está cadastrado no sistema') do |email|
  ensure_email_not_registered(email)
end

# Gera link de redefinição e salva em @link_definicao.
#
# Argumentos:
#   - email (String): Email.
#
# Efeitos Colaterais:
#   - Cria Usuario (se faltar), gera token.
Dado('que o usuário {string} solicitou um link de redefinição válido') do |email|
  generate_valid_reset_link(email)
end

# Prepara usuário com status específico.
#
# Argumentos:
#   - email (String): Email.
#   - status_desc (String): "ativo" ou outro.
#
# Efeitos Colaterais:
#   - Cria Usuario.
Dado('que o usuário {string} está cadastrado no sistema com o status {string}') do |email, status_desc|
  create_user_with_specific_status(email, status_desc)
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica permanência na página.
#
# Argumentos:
#   - page_name (String): Nome da página.
Então('eu devo permanecer na página de {string}') do |page_name|
  expect(page).to have_current_path(path_to(page_name))
end

# Verifica que nenhum email foi enviado.
Então('nenhum e-mail deve ser enviado') do
  expect(ActionMailer::Base.deliveries.count).to eq(0)
end

# Verifica login com nova senha.
#
# Argumentos:
#   - email (String): Email.
#   - nova_senha (String): Senha.
#
# Efeitos Colaterais:
#   - Realiza fluxo de login via UI.
Então('o usuário {string} deve conseguir logar com a senha {string}') do |email, nova_senha|
  perform_login_verification(email, nova_senha)
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

# Cria usuário de teste ativo.
#
# Argumentos:
#   - email (String): Email.
def create_active_test_user(email)
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

# Remove usuário por email.
#
# Argumentos:
#   - email (String): Email.
def ensure_email_not_registered(email)
  Usuario.where(email: email).destroy_all
end

# Gera link e token.
#
# Argumentos:
#   - email (String): Email.
def generate_valid_reset_link(email)
  user = Usuario.find_by(email: email) || create_user_for_reset(email)
  token = user.signed_id(purpose: :redefinir_senha, expires_in: 15.minutes)
  @link_definicao = "/redefinir_senha/edit?token=#{token}"
end

# Cria usuário para reset.
#
# Argumentos:
#   - email (String): Email.
def create_user_for_reset(email)
  Usuario.create!(
    nome: "Usuário Teste",
    email: email,
    usuario: "2023#{rand(1000..9999)}",
    matricula: "2023#{rand(1000..9999)}",
    password: "PasswordAntiga123!",
    ocupacao: :discente,
    status: true
  )
end

# Cria usuário com status.
#
# Argumentos:
#   - email (String): Email.
#   - status_desc (String): "ativo" ou outro.
def create_user_with_specific_status(email, status_desc)
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

# Tenta login na UI.
#
# Argumentos:
#   - email (String): Email.
#   - nova_senha (String): Senha.
def perform_login_verification(email, nova_senha)
  visit '/login'
  fill_in 'Usuário', with: email
  fill_in 'Senha', with: nova_senha
  click_on 'Entrar'
  expect(page).to have_no_content("Entrar")
end