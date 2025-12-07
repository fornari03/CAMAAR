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

  # TODO: implementar com feature de login quando existir
  # visit '/login'

  # fill_in 'Usuário', with: @admin.usuario
  # fill_in 'Senha', with: 'password123'

  # click_button 'Entrar'
end

Dado('estou na página {string}') do |nome_da_pagina|
  visit path_to(nome_da_pagina)
end

# método auxiliar para traduzir nomes para rotas
def path_to(page_name)
  page_name = page_name.downcase
  case page_name
  when "gerenciamento"
    admin_gerenciamento_path 
    
  when "home", "inicial"
    root_path
    
  else
    raise "Não sei o caminho para a página '#{page_name}'. Adicione no step definition."
  end
end

Então('eu devo ver a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end