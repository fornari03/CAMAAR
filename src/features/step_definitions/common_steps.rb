# =========================================
# Contexto (Dado)
# =========================================

Dado('que eu estou logado como Administrador') do
  @admin = Usuario.find_by(usuario: 'admin') || Usuario.create!(
    nome: 'Admin', 
    email: 'admin@test.com', 
    matricula: '123456', 
    usuario: '123456', 
    password: 'senha123', 
    ocupacao: :admin, 
    status: true
  )
  visit "/login"
  
  fill_in "Usuário", with: @admin.email
  fill_in "Senha", with: "senha123"
  
  click_on "Entrar"
  
  expect(page).to have_content("Bem-vindo")
end

Dado(/^(?:que )?(?:eu )?estou na página(?: de)? "([^"]*)"$/) do |page_name|
  visit path_to(page_name)
end

Dado('que eu sou um {string} logado no sistema') do |role|
  ocupacao = resolve_occupation_from_role(role)
  @user = find_or_create_auth_user(role, ocupacao)
  perform_ui_login(@user.email, 'password')
  verify_login_success
end

# =========================================
# Ações (Quando)
# =========================================

Quando('eu acesso a página {string}') do |page_name|
  visit path_to(page_name)
end

Quando('eu clico no botão {string}') do |texto|
  case texto
  when "Exportar", "Baixar CSV"
    texto = "Exportar para CSV"
  end
   click_on texto
end

Quando('eu clico em {string}') do |link_or_button|
  click_on link_or_button
end

# =========================================
# Verificações (Então)
# =========================================

Então('eu devo permanecer na página {string}') do |page_name|
  caminho_esperado = path_to(page_name)
  expect(page.current_path).to eq(caminho_esperado)
end

Então('eu devo ver a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('eu devo ver a mensagem {string}') do |mensagem|
  texto = mensagem.sub(/\.$/, '')
  expect(page).to have_content(texto)
end

Então('eu devo ser redirecionado para a minha página inicial') do
  expect(current_path).to eq(root_path)
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

def path_to(page_name)
  path = resolve_static_path(page_name.downcase)
  return path if path

  path = resolve_dynamic_path(page_name)
  return path if path

  raise "Não sei o caminho para a página '#{page_name}'. Adicione no step definition."
end

def resolve_static_path(page_name)
  case page_name
  when "gerenciamento"              then admin_gerenciamento_path
  when "gerenciamento de templates" then templates_path
  when "templates"                  then templates_path
  when "templates/new"              then new_template_path
  when "formularios/new"            then new_formulario_path
  when "formularios/pendentes"      then pendentes_formularios_path
  when "home", "inicial", "dashboard" then root_path
  when "formularios"                then formularios_path
  when "defina sua senha"           then "/definir_senha"
  when "login"                      then login_path
  else nil
  end
end

def resolve_dynamic_path(page_name)
  if page_name =~ /^formularios\/(.+)$/
    titulo = $1.strip
    return resolve_formulario_result_path(titulo)
  end
  
  nil
end

def resolve_formulario_result_path(titulo)
  form = Formulario.find_by(titulo_envio: titulo)
  
  form ||= Formulario.where("lower(titulo_envio) = ?", titulo.downcase).first

  if form
    resultado_path(form.id)
  else
    # Retorna caminho inválido para fins de teste/debug (comportamento original)
    "/resultados/99999"
  end
end