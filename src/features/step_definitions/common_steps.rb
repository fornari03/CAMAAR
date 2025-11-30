Dado('que eu estou logado como Administrador') do
  @admin = Usuario.create!(
    nome: "Administrador",
    email: "admin@camaar.com",
    matricula: "000000",
    usuario: "000000",
    password: "p123",
    ocupacao: :admin,
    status: true
  )

  # visit '/login'

  # fill_in 'Usuário', with: @admin.usuario
  # fill_in 'Senha', with: 'password123'

  # click_button 'Entrar'
end

Dado('estou na página {string}') do |string|
  visit "/" + string
end

