Dado('que eu estou logado como administrador') do
  step 'que eu estou logado como Administrador'
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

Então('eu devo ver a mensagem do template {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

# Pending steps added
Dado('que existe um template {string}') do |template_name|
  criador = @admin || Usuario.first || Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true)
  Template.create!(titulo: template_name, criador: criador)
end

Quando('eu adiciono uma pergunta {string} do tipo {string}') do |question_text, type|
  click_button "Adicionar Questão"
  within all('.question-form').last do
    fill_in "Título da Questão", with: question_text
    
    select_option = case type
                    when "texto" then "Text"
                    when "numérica (1-5)" then "Text"
                    when "múltipla escolha" then "Radio"
                    else type.humanize
                    end
    
    select select_option, from: "Tipo da Questão"
    click_button "Salvar Questão"
  end
end

Quando('eu adiciono uma pergunta {string} do tipo {string} com opções {string}') do |question_text, type, options|
  # 1. Cria a estrutura base da pergunta
  create_base_question(question_text, type)
  
  # 2. Adiciona as opções se houver
  add_options_to_last_question(options)
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

Então('eu devo permanecer na página de novo template') do
  # On validation error, Rails renders the 'new' view but the URL is '/templates' (POST)
  # So we check for the presence of the "Novo Template" header instead of the exact URL
  expect(page).to have_css('h1', text: 'Novo Template')
end