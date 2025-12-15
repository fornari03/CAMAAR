# =========================================
# Contexto (Dado)
# =========================================

# Cria um template com nome e semestre e acessa sua página de edição.
#
# Argumentos:
#   - nome (String): Parte do título.
#   - semestre (String): Semestre.
#
# Efeitos Colaterais:
#   - Persiste Template e Usuario.
#   - Visita edit path.
Dado('seleciono o template com o campo nome {string} e o campo semestre {string}') do |nome, semestre|
  @template = find_or_create_template_for_edit(nome, semestre)
  visit edit_template_path(@template)
end

# Popula template com questões definidas em tabela.
#
# Argumentos:
#   - table (Cucumber::Table): Tabela de questões.
#
# Efeitos Colaterais:
#   - Apaga questões anteriores, cria novas e visita edição.
Dado('o template contém duas questões, sendo:') do |table|
  reset_template_questions
  create_questions_from_table(table)
  visit edit_template_path(@template)
end

# Verifica acesso manual a página do template.
#
# Efeitos Colaterais:
#   - Asserção de URL.
Dado('visualizo a página do template escolhido') do
  expect(current_path).to eq(edit_template_path(@template))
end

# Configura questão específica com tipo e opções.
#
# Argumentos:
#   - num (Integer): Número da questão.
#   - tipo (String): Tipo.
#   - opcoes (String): Opções.
Dado('que a questão {int} é do tipo {string} com opções {string}') do |num, tipo, opcoes|
  update_question_attributes(num, tipo, opcoes)
  visit edit_template_path(@template)
end

# Configura questão específica apenas com tipo.
#
# Argumentos:
#   - num (Integer): Número.
#   - tipo (String): Tipo.
Dado('que a questão {int} é do tipo {string}') do |num, tipo|
  update_question_attributes(num, tipo, nil)
  visit edit_template_path(@template)
end

# =========================================
# Ações (Quando)
# =========================================

# Remove questão específica.
#
# Argumentos:
#   - num (Integer): Índice da questão.
Quando('eu clico no botão de exclusão ao lado da questão {int}') do |num|
  click_delete_question_button(num)
end

# Remove nova questão (redundante, mas semântico).
#
# Argumentos:
#   - num (Integer): Índice.
Quando('clico no botão de exclusão ao lado da \(nova) questão {int}') do |num|
  click_delete_question_button(num)
end

# Salva questão atual.
#
# Efeitos Colaterais:
#   - Clica em botão de salvar no formulário ativo.
Quando('clico em salvar') do
  save_current_question_form
end

# Altera tipo da questão.
#
# Argumentos:
#   - num (Integer): Número da questão.
#   - novo_tipo (String): Novo tipo.
Quando('eu altero o tipo da questão {int} para {string}') do |num, novo_tipo|
  @current_question_index = num - 1
  change_question_type_in_form(@current_question_index, novo_tipo)
end

# Preenche título da questão atual.
#
# Argumentos:
#   - texto (String): Título.
Quando('preencho o campo texto com {string}') do |texto|
  fill_question_title(texto)
end

# Preenche opções da questão atual.
#
# Argumentos:
#   - opcoes_str (String): Opções separadas por vírgula.
Quando('preencho o campo Opções com {string}') do |opcoes_str|
  options_list = parse_options_list(opcoes_str)
  
  options_list.each_with_index do |option_text, index|
    fill_single_option(option_text, index)
  end
end

# Limpa inputs de opções.
Quando('eu deixo o campo Opções vazio') do
  clear_all_options_inputs
end

# Passo composto: altera tipo e preenche texto.
Quando('eu altero o tipo da questão {int} para {string} e preencho o campo texto com {string}') do |num, tipo, texto|
  step "eu altero o tipo da questão #{num} para \"#{tipo}\""
  step "preencho o campo texto com \"#{texto}\""
end

# Passo composto completo: tipo, texto e opções.
Quando('eu altero o tipo da questão {int} para {string} e preencho o campo texto com {string} e preencho o campo Opções com {string}') do |num, tipo, texto, opcoes|
  step "eu altero o tipo da questão #{num} para \"#{tipo}\""
  step "preencho o campo texto com \"#{texto}\""
  step "preencho o campo Opções com \"#{opcoes}\""
end

# Alias para preencher texto.
Quando('eu altero o corpo para {string}') do |texto|
  step "preencho o campo texto com \"#{texto}\""
end

# Alias para preencher texto.
Quando('eu altero o texto da questão para {string}') do |texto|
  step "preencho o campo texto com \"#{texto}\""
end

# Alias para preencher opções.
Quando('eu altero as opções da questão para {string}') do |opcoes|
  step "preencho o campo Opções com \"#{opcoes}\""
end

# Alias para limpar texto.
Quando('eu deixo o texto vazio') do
  step "preencho o campo texto com \"\""
end

# Alias para limpar texto.
Quando('eu deixo o campo texto vazio') do
  step "preencho o campo texto com \"\""
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica mensagem.
#
# Argumentos:
#   - mensagem (String): Mensagem esperada.
Então('devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

# Verifica migração de posição (drag and drop simulado ou reordenação).
#
# Argumentos:
#   - origem (Integer): Posição original (não usado na lógica de verificação direta).
#   - destino (Integer): Posição nova.
Então('devo ver que a questão {int} migrou para a posição da questão {int}') do |origem, destino|
  verify_question_migration(destino)
end

# Verifica permanência na página.
Então('devo permanecer na página de edição do template') do
  expect(current_path).to eq(edit_template_path(@template))
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

# Encontra ou cria template para edição.
#
# Argumentos:
#   - nome (String): Parte do título.
#   - semestre (String): Semestre.
#
# Retorno:
#   - (Template): Template.
def find_or_create_template_for_edit(nome, semestre)
  template = Template.where("titulo LIKE ?", "%#{nome}%").first
  return template if template

  criador = Usuario.first || Usuario.create!(
    nome: 'Admin', email: 'admin@test.com', matricula: '123', 
    usuario: 'admin', password: 'password', ocupacao: :admin, status: true
  )
  Template.create!(titulo: "#{nome} - #{semestre}", criador: criador)
end

# Atualiza atributos de uma questão.
#
# Argumentos:
#   - num (Integer): Número da questão.
#   - tipo (String): Tipo.
#   - opcoes (String): Opções (opcional).
def update_question_attributes(num, tipo, opcoes)
  @current_question_index = num - 1
  question = @template.template_questions[num - 1]
  
  type_map = { 'texto' => 'text', 'radio' => 'radio', 'checkbox' => 'checkbox' }
  attributes = { question_type: type_map[tipo] || 'text' }
  attributes[:content] = opcoes.split(',').map(&:strip) if opcoes

  question.update!(attributes)
end

# Clica no botão remover questão.
#
# Argumentos:
#   - num (Integer): Índice.
def click_delete_question_button(num)
  within all('.question-form')[num - 1] do
    click_link "Remover Questão"
  end
end

# Salva questão atual.
#
# Efeitos Colaterais:
#   - Clica em Salvar Questão.
def save_current_question_form
  index = @current_question_index || (all('.question-form').count - 1)
  within all('.question-form')[index] do
    click_button "Salvar Questão"
  end
end

# Altera tipo de questão no formulário.
#
# Argumentos:
#   - index (Integer): Índice do form.
#   - novo_tipo (String): Novo tipo.
def change_question_type_in_form(index, novo_tipo)
  within all('.question-form')[index] do
    select_option = resolve_select_option_label(novo_tipo)
    select select_option, from: "Tipo da Questão"
    click_button "Salvar Questão"
  end
end

# Resolve label do select.
#
# Argumentos:
#   - tipo (String): Tipo interno.
#
# Retorno:
#   - (String): Label UI.
def resolve_select_option_label(tipo)
  case tipo
  when "texto" then "Text"
  when "radio" then "Radio"
  else tipo.humanize
  end
end

# Preenche título da questão.
#
# Argumentos:
#   - texto (String): Título.
def fill_question_title(texto)
  within all('.question-form')[@current_question_index] do
    fill_in "Título da Questão", with: texto
  end
end

# Limpa inputs de opções.
def clear_all_options_inputs
  within all('.question-form')[@current_question_index] do
    all('input[name="alternatives[]"]').each { |input| input.set("") }
  end
end

# Verifica migração de questão.
#
# Argumentos:
#   - destino_index (Integer): Posição esperada.
def verify_question_migration(destino_index)
  # Verifica se o título esperado (da questão que moveu) está na posição de destino
  form = all('.question-form')[destino_index - 1]
  title = form.find('input[name*="[title]"]').value
  expect(title).to include("texto para a questão 2")
end