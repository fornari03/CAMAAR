# =========================================
# Contexto (Dado)
# =========================================

# Alias para login admin.
Dado('que eu estou logado como administrador') do
  step 'que eu estou logado como Administrador'
end

# Visita página de criação de template.
Dado('que eu estou na página de novo template') do
  visit new_template_path
end

# Cria template com título.
#
# Argumentos:
#   - titulo (String): Título.
#
# Efeitos Colaterais:
#   - Cria Template, Usuario (se necessário).
Dado('que existe um template chamado {string}') do |titulo|
  criador = @admin || Usuario.first || Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true)
  Template.create!(titulo: titulo, criador: criador)
end

# Varição do passo anterior.
Dado('que existe um template {string}') do |template_name|
  criador = @admin || Usuario.first || Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true)
  Template.create!(titulo: template_name, criador: criador)
end

# Visita edição de template.
#
# Argumentos:
#   - titulo (String): Título.
Dado('que eu estou na página de edição de {string}') do |titulo|
  template = Template.find_by!(titulo: titulo)
  visit edit_template_path(template)
end

# Visita listagem de templates.
Dado('que eu estou na página de listagem de templates') do
  visit templates_path
end

# =========================================
# Ações (Quando)
# =========================================

# Preenche campo de formulário.
#
# Argumentos:
#   - campo (String): Label.
#   - valor (String): Valor.
Quando('eu preencho o campo do template {string} com {string}') do |campo, valor|
  fill_in campo, with: valor
end

# Clica em botão.
#
# Argumentos:
#   - botao (String): Texto do botão.
Quando('eu clico no botão do template {string}') do |botao|
  click_button botao
end

# Clica em link/botão dentro de uma linha de tabela.
#
# Argumentos:
#   - link_text (String): Ação.
#   - template_titulo (String): Linha alvo.
Quando('eu clico em {string} para {string}') do |link_text, template_titulo|
  row = find('tr', text: template_titulo)
  within(row) do
    click_link_or_button link_text
  end
end

# Adiciona questão via UI.
#
# Argumentos:
#   - question_text (String): Título questão.
#   - type (String): Tipo.
#
# Efeitos Colaterais:
#   - Adiciona fieldset dinâmico, preenche e salva.
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

# Cria questão com opções mocks (sem UI completa).
#
# Argumentos:
#   - question_text (String): Texto.
#   - type (String): Tipo.
#   - options (String): Opções.
#
# Efeitos Colaterais:
#   - Usa helpers de factories_helpers e template_helpers.
Quando('eu adiciono uma pergunta {string} do tipo {string} com opções {string}') do |question_text, type, options|
  create_base_question(question_text, type)
  add_options_to_last_question(options)
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica redirecionamento para edição.
#
# Argumentos:
#   - titulo (String): Título.
Então('eu devo ser redirecionado para a página de edição do template {string}') do |titulo|
  template = Template.find_by!(titulo: titulo)
  expect(current_path).to eq(edit_template_path(template))
end

# Verifica mensagem na tela.
Então('eu devo ver a mensagem do template {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

# Verifica ausência de conteúdo.
Então('eu não devo ver {string}') do |conteudo|
  expect(page).not_to have_content(conteudo)
end

# Verifica título do último template.
Então('o nome do template deve ser {string}') do |titulo|
  expect(Template.last.titulo).to eq(titulo)
end

# Verifica persistência e status hidden (soft delete provável).
#
# Argumentos:
#   - titulo (String): Título.
Então('o template {string} deve continuar existindo no banco de dados') do |titulo|
  template = Template.unscoped.find_by(titulo: titulo)
  expect(template).not_to be_nil
  expect(template.hidden).to be true
end

# Verifica cabeçalho da página.
Então('eu devo permanecer na página de novo template') do
  expect(page).to have_css('h1', text: 'Novo Template')
end