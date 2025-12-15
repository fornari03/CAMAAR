Dado('(que )existe um formulário {string}') do |titulo_form|
  # 1. Prepara as dependências (Docente, Matéria, Turma, Template)
  contexto = find_or_create_form_dependencies
  
  # 2. Cria o formulário usando o contexto preparado
  @formulario_relatorio = create_formulario_relatorio(titulo_form, contexto)
end

Dado('o formulário {string} tem {string} respostas submetidas') do |titulo_form, qtd_str|
  form = Formulario.find_by(titulo_envio: titulo_form)
  
  # Itera criando submissões individuais
  qtd_str.to_i.times do |index|
    create_student_submission(form, index)
  end
end

Dado('que eu estou na página de resultados do formulário {string}') do |titulo_form|
  form = Formulario.find_by(titulo_envio: titulo_form)
  visit resultado_path(form)
end

Então('um download de um arquivo {string} deve ser iniciado') do |nome_arquivo|
  verify_csv_download_response(nome_arquivo)
end

Então('nenhum download deve ser iniciado') do
  expect(page.response_headers['Content-Type']).to include('text/html')
  expect(page.response_headers['Content-Disposition']).to be_nil
end