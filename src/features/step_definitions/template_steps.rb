Dado('que eu estou logado como administrador') do
  @admin = Usuario.find_by(usuario: 'admin') || Usuario.create!(
    nome: 'Admin', 
    email: 'admin@test.com', 
    matricula: '123456', 
    usuario: 'admin', 
    password: 'password', 
    ocupacao: :admin, 
    status: true
  )
  
  # Login bypassed via ApplicationController#current_usuario
end

Dado('que eu estou na página de novo template') do
  visit new_template_path
end

Dado('que existe um template chamado {string}') do |titulo|
  # Ensure admin exists
  criador = @admin || Usuario.first || Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true)
  Template.create!(titulo: titulo, criador: criador)
end

Dado('que eu estou na página de edição de {string}') do |titulo|
  template = Template.find_by!(titulo: titulo)
  visit edit_template_path(template)
end

Dado('que eu estou na página de listagem de templates') do
  visit templates_path
end

Quando('eu preencho o campo do template {string} com {string}') do |campo, valor|
  fill_in campo, with: valor
end

Quando('eu clico no botão do template {string}') do |botao|
  click_button botao
end



Quando('eu clico em {string} para {string}') do |link_text, template_titulo|
  row = find('tr', text: template_titulo)
  within(row) do
    click_link_or_button link_text
  end
end

Então('eu devo ser redirecionado para a página de edição do template {string}') do |titulo|
  template = Template.find_by!(titulo: titulo)
  expect(current_path).to eq(edit_template_path(template))
end

Então('eu devo ver a mensagem do template {string}') do |conteudo|
  expect(page).to have_content(conteudo)
end



Então('eu não devo ver {string}') do |conteudo|
  expect(page).not_to have_content(conteudo)
end

Então('o nome do template deve ser {string}') do |titulo|
  expect(Template.last.titulo).to eq(titulo)
end

Então('o template {string} deve continuar existindo no banco de dados') do |titulo|
  template = Template.unscoped.find_by(titulo: titulo)
  expect(template).not_to be_nil
  expect(template.hidden).to be true
end