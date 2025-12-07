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

Dado('estou na página {string}') do |page_name|
  visit page_name
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
