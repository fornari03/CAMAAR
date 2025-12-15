# --- Criação da Pergunta Base ---

def create_base_question(title, type)
  click_button "Adicionar Questão"
  
  within all('.question-form').last do
    fill_in "Título da Questão", with: title
    select resolve_question_type_label(type), from: "Tipo da Questão"
    click_button "Salvar Questão"
  end
end

def resolve_question_type_label(type)
  case type.downcase
  when "múltipla escolha" then "Radio"
  when "caixa de seleção" then "Checkbox"
  else type.humanize
  end
end

# --- Inserção de Opções ---

def add_options_to_last_question(options_str)
  return if options_str.blank?

  options_str.split(',').each do |option|
    append_single_option(option.strip)
  end
end

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

def parse_options_list(str)
  str.split(',').map(&:strip)
end

# --- Orquestrador de Preenchimento ---

def fill_single_option(text, index)
  # 1. Garante que existe um input disponível para esse índice
  ensure_alternative_input_exists(index)

  # 2. Preenche o input (buscando o elemento novamente para evitar StaleElementError)
  set_alternative_input_value(index, text)
end

# --- Interação com DOM ---

def ensure_alternative_input_exists(target_index)
  # Verifica quantos inputs existem atualmente na questão
  current_inputs = find_current_alternatives_inputs
  
  # Se o índice alvo for maior ou igual à quantidade atual, precisa criar um novo
  if target_index >= current_inputs.size
    click_add_alternative_button
  end
end

def click_add_alternative_button
  within current_question_scope do
    click_button "Adicionar Alternativa"
  end
  # O clique causa refresh, então não retornamos nada aqui
end

def set_alternative_input_value(index, text)
  # Busca os inputs novamente (pós-refresh)
  inputs = find_current_alternatives_inputs
  
  # Define o valor no input correto
  inputs[index].set(text)
end

# --- Scopes e Queries ---

def current_question_scope
  # Retorna o escopo da questão atual baseada na variável de instância
  all('.question-form')[@current_question_index]
end

def find_current_alternatives_inputs
  current_question_scope.all('input[name="alternatives[]"]')
end

# --- Gerenciamento de Estado ---

def reset_template_questions
  @template.template_questions.destroy_all
end

def create_questions_from_table(table)
  table.hashes.each do |row|
    create_single_template_question(row)
  end
end

# --- Fábrica de Questões (Factory) ---

def create_single_template_question(row)
  @template.template_questions.create!(
    title: row['texto'],
    question_type: resolve_question_type(row['tipo']),
    content: parse_question_options(row['opções'])
  )
end

# --- Parsers e Mappers ---

def resolve_question_type(type_name)
  type_map = { 
    'texto' => 'text', 
    'radio' => 'radio', 
    'checkbox' => 'checkbox' 
  }
  
  type_map[type_name] || 'text'
end

def parse_question_options(options_str)
  return [] if options_str.blank?
  
  options_str.split(',').map(&:strip)
end