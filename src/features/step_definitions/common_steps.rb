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

Quando('eu acesso a página {string}') do |page_name|
  visit path_to(page_name)
end

Quando('eu clico no botão {string}') do |texto|
   click_on texto
end


def path_to(page_name)
  case page_name.downcase
  when "gerenciamento"
    admin_gerenciamento_path

  when "gerenciamento de templates"
    templates_path
    
  when "templates"
    templates_path
    
  when "templates/new"
    new_template_path
    
  when "formularios/new"
    new_formulario_path
    
  when "home", "inicial", "dashboard"
    root_path

  when "formularios"
    # Assuming this is the results index page for admin
    resultados_path

  when /^formularios\/(.+)$/
    titulo = $1.strip
    form = Formulario.find_by(titulo_envio: titulo)
    
    unless form
      # Fallback: try case insensitive
      form = Formulario.where("lower(titulo_envio) = ?", titulo.downcase).first
    end

    if form
       resultado_path(form.id)
    else
       # Log failure for debugging if strict mode (or just return invalid path)
       "/resultados/99999"
    end

  when "defina sua senha"
    "/definir_senha"

  when "login"
    login_path
    
  else
    raise "Não sei o caminho para a página '#{page_name}'. Adicione no step definition."
  end
end

Então('eu devo permanecer na página {string}') do |page_name|
  caminho_esperado = path_to(page_name)
  expect(page.current_path).to eq(caminho_esperado)
end

Dado('que eu sou um {string} logado no sistema') do |role|
  ocupacao = role.downcase.to_sym

  email_teste = "#{role}@test.com"
  
  @user = Usuario.find_by(email: email_teste) || Usuario.create!(
    nome: role.capitalize, 
    email: email_teste, 
    matricula: "99#{rand(1000..9999)}",
    usuario: role, 
    password: 'password', 
    password_confirmation: 'password',
    ocupacao: ocupacao, 
    status: true
  )
  visit '/login'

  fill_in 'Usuário', with: @user.email 
  fill_in 'Senha', with: 'password'

  click_on 'Entrar'

  expect(page).to have_no_content("Entrar") 
  # Removed duplicate step definition because it caused ambiguity
end

# Removed duplicate 'que eu sou um {string} logado no sistema' if it exists here or elsewhere.
# common_steps.rb:50 has it.


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

Quando('eu clico em {string}') do |link_or_button|
  click_on link_or_button
end
