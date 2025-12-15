# --- Mapeamento de Papéis ---

# Resolve o papel do usuário para o enum de ocupação.
#
# Argumentos:
#   - role_name (String): Nome do papel (ex: 'participante', 'professor').
#
# Retorno:
#   - (Symbol): Símbolo correspondente à ocupação (:discente, :docente, :admin).
def resolve_occupation_from_role(role_name)
  map = {
    'participante' => :discente,
    'aluno'        => :discente,
    'professor'    => :docente,
    'admin'        => :admin
  }
  
  map[role_name.downcase] || role_name.downcase.to_sym
end

# --- Persistência de Usuário ---

# Encontra ou cria um usuário de teste para autenticação.
#
# Argumentos:
#   - role_name (String): Nome base para email e identificação.
#   - occupation (Symbol): Ocupação do usuário.
#
# Retorno:
#   - (Usuario): Objeto Usuário persistido.
def find_or_create_auth_user(role_name, occupation)
  email = "#{role_name}@test.com"
  
  Usuario.find_by(email: email) || create_test_user(role_name, email, occupation)
end

# Cria um usuário de teste.
#
# Argumentos:
#   - name_base (String): Base para o nome e usuário.
#   - email (String): Email do usuário.
#   - occupation (Symbol): Ocupação.
#
# Retorno:
#   - (Usuario): Novo usuário criado.
def create_test_user(name_base, email, occupation)
  Usuario.create!(
    nome: name_base.capitalize, 
    email: email, 
    matricula: "99#{rand(1000..9999)}",
    usuario: name_base, 
    password: 'password', 
    password_confirmation: 'password',
    ocupacao: occupation, 
    status: true
  )
end

# --- Ações de UI ---

# Realiza login na interface web.
#
# Argumentos:
#   - email (String): Email do usuário.
#   - password (String): Senha do usuário.
#
# Efeitos Colaterais:
#   - Visita /login e submete o formulário.
def perform_ui_login(email, password)
  visit '/login'

  fill_in 'Usuário', with: email 
  fill_in 'Senha', with: password

  click_on 'Entrar'
end

# Verifica se o login foi bem sucedido.
#
# Efeitos Colaterais:
#   - Dispara erro se o botão 'Entrar' ainda estiver visível.
def verify_login_success
  # Verifica que o botão de entrar sumiu (indicando sessão ativa)
  expect(page).to have_no_content("Entrar")
end

# --- Mapeamento de Papéis ---

# Resolve a ocupação para respondentes.
#
# Argumentos:
#   - role (String): Papel descrito.
#
# Retorno:
#   - (Symbol): Ocupação correspondente.
def resolve_responder_occupation(role)
  # Lógica original: 'participante' vira :discente, o resto vira symbol direto
  return :discente if role.downcase == 'participante'
  
  role.downcase.to_sym
end

# --- Persistência de Usuário ---

# Encontra ou cria um usuário respondente.
#
# Argumentos:
#   - username (String): Nome de usuário.
#   - occupation (Symbol): Ocupação.
#
# Retorno:
#   - (Usuario): Usuário encontrado ou criado.
def find_or_create_responder_user(username, occupation)
  Usuario.find_by(usuario: username) || create_responder_user(username, occupation)
end

# Cria usuário respondente específico.
#
# Argumentos:
#   - username (String): Nome de usuário.
#   - occupation (Symbol): Ocupação.
#
# Retorno:
#   - (Usuario): Novo usuário.
def create_responder_user(username, occupation)
  Usuario.create!(
    nome: username.capitalize,
    email: "#{username}@test.com",
    matricula: "2021#{rand(1000..9999)}",
    usuario: username,
    password: 'password', 
    ocupacao: occupation,
    status: true
  )
end