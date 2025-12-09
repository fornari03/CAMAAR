Dado('que eu estou logado como Administrador') do
  @admin = Usuario.find_by(usuario: 'admin') || Usuario.create!(
    nome: 'Admin', 
    email: 'admin@test.com', 
    matricula: '123456', 
    usuario: 'admin', 
    password: 'senha123', 
    ocupacao: :admin, 
    status: true
  )
  visit "/login"
  
  fill_in "Email", with: @admin.email
  fill_in "Senha", with: "senha123"
  
  click_on "Entrar"
  
  expect(page).to have_content("Bem-vindo")
end

Dado(/^(?:que )?(?:eu )?estou na página(?: de)? "([^"]*)"$/) do |page_name|
  visit path_to(page_name)
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
    
  when "home", "inicial"
    root_path
    
  else
    raise "Não sei o caminho para a página '#{page_name}'. Adicione no step definition."
  end
end

Dado('que eu sou um {string} logado no sistema') do |role|
  # Mocking login based on role
  # This is a placeholder for now, similar to the admin login step
  @user = Usuario.find_by(usuario: role) || Usuario.create!(
    nome: role.capitalize, 
    email: "#{role}@test.com", 
    matricula: '123456', 
    usuario: role, 
    password: 'password', 
    ocupacao: role.to_sym, # Assuming enum matches role string
    status: true
  )
end

Então('eu devo ver a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
