# --- Mapeamento de Papéis ---

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

def find_or_create_auth_user(role_name, occupation)
  email = "#{role_name}@test.com"
  
  Usuario.find_by(email: email) || create_test_user(role_name, email, occupation)
end

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

def perform_ui_login(email, password)
  visit '/login'

  fill_in 'Usuário', with: email 
  fill_in 'Senha', with: password

  click_on 'Entrar'
end

def verify_login_success
  # Verifica que o botão de entrar sumiu (indicando sessão ativa)
  expect(page).to have_no_content("Entrar")
end

# --- Mapeamento de Papéis ---

def resolve_responder_occupation(role)
  # Lógica original: 'participante' vira :discente, o resto vira symbol direto
  return :discente if role.downcase == 'participante'
  
  role.downcase.to_sym
end

# --- Persistência de Usuário ---

def find_or_create_responder_user(username, occupation)
  Usuario.find_by(usuario: username) || create_responder_user(username, occupation)
end

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

# --- Automação de Login ---

def perform_ui_login(email, password)
  visit '/login'
  fill_in 'Usuário', with: email
  fill_in 'Senha', with: password
  click_on 'Entrar'
end