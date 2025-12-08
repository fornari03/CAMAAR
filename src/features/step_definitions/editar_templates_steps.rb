# features/step_definitions/editar_templates_steps.rb

Dado('que estou na página de gerenciamento') do
  visit templates_path
end

Dado('seleciono o template com o campo nome {string} e o campo semestre {string}') do |nome, semestre|
  # Assuming the template exists or creating it if not found to satisfy the test context
  # Concatenating semester to title if needed, or just finding by name part
  @template = Template.where("titulo LIKE ?", "%#{nome}%").first
  unless @template
    criador = Usuario.first || Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true)
    @template = Template.create!(titulo: "#{nome} - #{semestre}", criador: criador)
  end
  
  # Find the row and click edit
  # Assuming the list shows the title
  # If the title is "Template1 - 2025.2", and we look for "Template1", we might need partial match
  # But for clicking, we can just visit the path
  visit edit_template_path(@template)
end

Dado('o template contém duas questões, sendo:') do |table|
  @template.template_questions.destroy_all # Clear existing
  
  table.hashes.each do |row|
    type_map = { 'texto' => 'text', 'radio' => 'radio', 'checkbox' => 'checkbox' }
    type = type_map[row['tipo']] || 'text'
    content = row['opções'] ? row['opções'].split(',').map(&:strip) : []
    
    @template.template_questions.create!(
      title: row['texto'],
      question_type: type,
      content: content
    )
  end
  visit edit_template_path(@template)
end

Dado('visualizo a página do template escolhido') do
  expect(current_path).to eq(edit_template_path(@template))
end

Quando('eu clico no botão de exclusão ao lado da questão {int}') do |num|
  within all('.question-form')[num - 1] do
    # accept_confirm do
      click_link "Remover Questão"
    # end
  end
end

Quando('clico em salvar') do
  # Assuming the last modified question form
  index = @current_question_index || (all('.question-form').count - 1)
  within all('.question-form')[index] do
    click_button "Salvar Questão"
  end
end

Então('devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('devo ver que a questão {int} migrou para a posição da questão {int}') do |origem, destino|
  # Verify that the question that was at 'origem' (e.g. 2) is now at 'destino' (e.g. 1)
  # This assumes we know the content.
  # Based on the scenario: Q1 deleted, Q2 (title "texto para a questão 2") moves to pos 1.
  title = all('.question-form')[destino - 1].find('input[name*="[title]"]').value
  expect(title).to include("texto para a questão 2")
end

Quando('clico no botão de exclusão ao lado da \(nova) questão {int}') do |num|
  within all('.question-form')[num - 1] do
    # accept_confirm do
      click_link "Remover Questão"
    # end
  end
end

Então('devo permanecer na página de edição do template') do
  expect(current_path).to eq(edit_template_path(@template))
end

Dado('que a questão {int} é do tipo {string} com opções {string}') do |num, tipo, opcoes|
  @current_question_index = num - 1
  q = @template.template_questions[num - 1]
  type_map = { 'texto' => 'text', 'radio' => 'radio', 'checkbox' => 'checkbox' }
  q.update!(question_type: type_map[tipo] || 'text', content: opcoes.split(',').map(&:strip))
  visit edit_template_path(@template)
end

Dado('que a questão {int} é do tipo {string}') do |num, tipo|
  @current_question_index = num - 1
  q = @template.template_questions[num - 1]
  type_map = { 'texto' => 'text', 'radio' => 'radio', 'checkbox' => 'checkbox' }
  q.update!(question_type: type_map[tipo] || 'text')
  visit edit_template_path(@template)
end

Quando('eu altero o tipo da questão {int} para {string}') do |num, novo_tipo|
  @current_question_index = num - 1
  within all('.question-form')[@current_question_index] do
    select_option = case novo_tipo
                    when "texto" then "Text"
                    when "radio" then "Radio"
                    else novo_tipo.humanize
                    end
    select select_option, from: "Tipo da Questão"
    click_button "Salvar Questão" # Save to persist type change for rack_test
  end
end

Quando('preencho o campo texto com {string}') do |texto|
  within all('.question-form')[@current_question_index] do
    fill_in "Título da Questão", with: texto
  end
end

Quando('preencho o campo Opções com {string}') do |opcoes|
  # This implies adding alternatives or editing existing ones.
  # Since the UI requires adding them one by one, this is tricky if they don't exist.
  # But if we changed type to radio, we might not have inputs yet.
  # So we should add them.
  
  within all('.question-form')[@current_question_index] do
    # First, clear existing? Or assume empty?
    # If we just changed type, it's empty.
    # But we can't easily clear inputs that don't exist.
    
    # We need to click "Adicionar Alternativa" for each option.
    # But we can't do that inside this `within` if we want to fill them all at once without saving.
    # Wait, as discussed, we need to save after each add?
    # Or we can add N alternatives then fill them?
    # No, adding alternative reloads page.
    # So this step needs to handle the reload loop.
    # But `preencho` usually implies just filling fields.
    # If the implementation requires clicking buttons, we should do it.
  end
  
  opcoes.split(',').each do |option|
    within all('.question-form')[@current_question_index] do
      click_button "Adicionar Alternativa"
    end
    # Page reloads
    within all('.question-form')[@current_question_index] do
      all('input[name="alternatives[]"]').last.set(option.strip)
      click_button "Salvar Questão"
    end
  end
end

Quando('eu altero o tipo da questão {int} para {string} e preencho o campo texto com {string}') do |num, tipo, texto|
  step "eu altero o tipo da questão #{num} para \"#{tipo}\""
  step "preencho o campo texto com \"#{texto}\""
end

Quando('eu altero o tipo da questão {int} para {string} e preencho o campo texto com {string} e preencho o campo Opções com {string}') do |num, tipo, texto, opcoes|
  step "eu altero o tipo da questão #{num} para \"#{tipo}\""
  step "preencho o campo texto com \"#{texto}\""
  step "preencho o campo Opções com \"#{opcoes}\""
end

Quando('eu altero o corpo para {string}') do |texto|
  step "preencho o campo texto com \"#{texto}\""
end

Quando('eu altero o texto da questão para {string}') do |texto|
  step "preencho o campo texto com \"#{texto}\""
end

Quando('eu altero as opções da questão para {string}') do |opcoes|
  step "preencho o campo Opções com \"#{opcoes}\""
end

Quando('eu deixo o texto vazio') do
  step "preencho o campo texto com \"\""
end

Quando('eu deixo o campo texto vazio') do
  step "preencho o campo texto com \"\""
end

Quando('eu deixo o campo Opções vazio') do
  within all('.question-form')[@current_question_index] do
    all('input[name="alternatives[]"]').each do |input|
      input.set("")
    end
  end
end
