# --- Criação da Pergunta Base ---

# Cria uma pergunta básica no formulário.
#
# Argumentos:
#   - title (String): Título da pergunta.
#   - type (String): Tipo da pergunta (Múltipla escolha, Texto, etc).
#
# Efeitos Colaterais:
#   - Interage com formulário de criação de questão.
def create_base_question(title, type)
  click_button "Adicionar Questão"
  
  within all('.question-form').last do
    fill_in "Título da Questão", with: title
    select resolve_question_type_label(type), from: "Tipo da Questão"
    click_button "Salvar Questão"
  end
end

# Resolve o label do tipo de questão para a UI.
#
# Argumentos:
#   - type (String): Tipo em português.
#
# Retorno:
#   - (String): Label correspondente no select input.
def resolve_question_type_label(type)
  case type.downcase
  when "múltipla escolha" then "Radio"
  when "caixa de seleção" then "Checkbox"
  else type.humanize
  end
end

# --- Inserção de Opções ---

# Adiciona opções à última pergunta criada.
#
# Argumentos:
#   - options_str (String): String de opções separadas por vírgula.
#
# Efeitos Colaterais:
#   - Chamadas múltiplas a append_single_option.
def add_options_to_last_question(options_str)
  return if options_str.blank?

  options_str.split(',').each do |option|
    append_single_option(option.strip)
  end
end

# Adiciona uma única opção a uma questão (tratando refresh).
#
# Argumentos:
#   - option_text (String): Texto da opção.
def append_single_option(option_text)
  # Ação 1: Clicar em "Adicionar Alternativa"
  # Buscamos o formulário e clicamos. Isso vai disparar o refresh.
  within(all('.question-form').last) do
    click_button "Adicionar Alternativa"
  end

  # Ação 2: Preencher e Salvar
  # O DOM foi atualizado. Precisamos buscar o formulário ('.question-form') NOVAMENTE.
  # Se usássemos a referência antiga, daria o erro StaleElementReferenceError.
  within(all('.question-form').last) do
    # Encontra o input recém-criado (o último da lista)
    all('input[name="alternatives[]"]').last.set(option_text)
    
    click_button "Salvar Questão"
  end
end

# --- Parsing ---

# Analisa string lista de opções.
#
# Argumentos:
#   - str (String): Opções separadas por vírgula.
#
# Retorno:
#   - (Array<String>): Lista limpa.
def parse_options_list(str)
  str.split(',').map(&:strip)
end

# --- Orquestrador de Preenchimento ---

# Preenche uma única opção.
#
# Argumentos:
#   - text (String): Texto.
#   - index (Integer): Índice.
def fill_single_option(text, index)
  # 1. Garante que existe um input disponível para esse índice
  ensure_alternative_input_exists(index)

  # 2. Preenche o input (buscando o elemento novamente para evitar StaleElementError)
  set_alternative_input_value(index, text)
end

# --- Interação com DOM ---

# Garante existência de input para alternativa.
#
# Argumentos:
#   - target_index (Integer): Índice desejado.
def ensure_alternative_input_exists(target_index)
  # Verifica quantos inputs existem atualmente na questão
  current_inputs = find_current_alternatives_inputs
  
  # Se o índice alvo for maior ou igual à quantidade atual, precisa criar um novo
  if target_index >= current_inputs.size
    click_add_alternative_button
  end
end

# Clica no botão de adicionar alternativa.
#
# Efeitos Colaterais:
#   - Refresh da página.
def click_add_alternative_button
  within current_question_scope do
    click_button "Adicionar Alternativa"
  end
  # O clique causa refresh, então não retornamos nada aqui
end

# Define valor do input de alternativa.
#
# Argumentos:
#   - index (Integer): Índice.
#   - text (String): Texto.
def set_alternative_input_value(index, text)
  # Busca os inputs novamente (pós-refresh)
  inputs = find_current_alternatives_inputs
  
  # Define o valor no input correto
  inputs[index].set(text)
end

# --- Scopes e Queries ---

# Obtém escopo da questão atual.
#
# Retorno:
#   - (Capybara::Node::Element): Elemento da questão.
def current_question_scope
  # Retorna o escopo da questão atual baseada na variável de instância
  all('.question-form')[@current_question_index]
end

# Encontra inputs de alternativas atuais.
#
# Retorno:
#   - (Capybara::Result): Lista de inputs.
def find_current_alternatives_inputs
  current_question_scope.all('input[name="alternatives[]"]')
end

# --- Gerenciamento de Estado ---

# Reseta questões do template.
#
# Efeitos Colaterais:
#   - Remove todas as questões associadas.
def reset_template_questions
  @template.template_questions.destroy_all
end

# Cria questões a partir de tabela Cucumber.
#
# Argumentos:
#   - table (Cucumber::Table): Tabela de dados.
def create_questions_from_table(table)
  table.hashes.each do |row|
    create_single_template_question(row)
  end
end

# --- Fábrica de Questões (Factory) ---

# Cria uma única questão de template.
#
# Argumentos:
#   - row (Hash): Linha de dados (texto, tipo, opções).
#
# Efeitos Colaterais:
#   - Cria TemplateQuestion.
def create_single_template_question(row)
  @template.template_questions.create!(
    title: row['texto'],
    question_type: resolve_question_type(row['tipo']),
    content: parse_question_options(row['opções'])
  )
end

# --- Parsers e Mappers ---

# Resolve tipo de questão p/ banco de dados.
#
# Argumentos:
#   - type_name (String): Nome do tipo.
#
# Retorno:
#   - (String): Tipo normalizado ('text', 'radio', 'checkbox').
def resolve_question_type(type_name)
  type_map = { 
    'texto' => 'text', 
    'radio' => 'radio', 
    'checkbox' => 'checkbox' 
  }
  
  type_map[type_name] || 'text'
end

# Parseia string de opções para array JSON.
#
# Argumentos:
#   - options_str (String): String separada por vírgula.
#
# Retorno:
#   - (Array<String>): Array de opções.
def parse_question_options(options_str)
  return [] if options_str.blank?
  
  options_str.split(',').map(&:strip)
end