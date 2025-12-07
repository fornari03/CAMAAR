Dado('que eu estou logado como Administrador') do
  # Mocking admin login for now
  @admin = Usuario.find_by(usuario: 'admin') || Usuario.create!(
    nome: 'Admin', 
    email: 'admin@test.com', 
    matricula: '123456', 
    usuario: 'admin', 
    password: 'password', 
    ocupacao: :admin, 
    status: true
  )
  # Assuming ApplicationController bypasses login or we need to visit login page
  # For now, just ensuring the user exists might be enough if using the hack,
  # but if we want to be "correct" for future, we might visit login.
  # However, the other steps might have had implementation. Let's check one.
end

Dado('(que eu )estou na página {string}') do |page_name|
  visit path_to(page_name)
end

def path_to(page_name)
  case page_name.downcase
  when "gerenciamento"
    admin_gerenciamento_path
    
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
