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