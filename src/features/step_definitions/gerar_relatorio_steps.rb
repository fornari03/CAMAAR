# =========================================
# Contexto (Dado)
# =========================================

# Cria um formulário para relatório.
#
# Argumentos:
#   - titulo_form (String): Título do formulário.
#
# Efeitos Colaterais:
#   - Persiste User, Template, Formulario.
Dado('(que )existe um formulário {string}') do |titulo_form|
  contexto = find_or_create_form_dependencies
  @formulario_relatorio = create_formulario_relatorio(titulo_form, contexto)
end

# Cria respostas mockadas para um formulário.
#
# Argumentos:
#   - titulo_form (String): Título do formulário.
#   - qtd_str (String): Quantidade de respostas.
#
# Efeitos Colaterais:
#   - Cria Usuario, Matricula, Resposta.
Dado('o formulário {string} tem {string} respostas submetidas') do |titulo_form, qtd_str|
  form = Formulario.find_by(titulo_envio: titulo_form)
  
  qtd_str.to_i.times do |index|
    create_student_submission(form, index)
  end
end

# Acessa página de resultados do formulário.
#
# Argumentos:
#   - titulo_form (String): Título do formulário.
#
# Efeitos Colaterais:
#   - Visita URL de resultados.
Dado('que eu estou na página de resultados do formulário {string}') do |titulo_form|
  form = Formulario.find_by(titulo_envio: titulo_form)
  visit resultado_path(form)
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica download de arquivo CSV.
#
# Argumentos:
#   - nome_arquivo (String): Nome esperado do arquivo.
#
# Retorno:
#   - (Boolean): Asserção de headers.
Então('um download de um arquivo {string} deve ser iniciado') do |nome_arquivo|
  verify_csv_download_response(nome_arquivo)
end

# Verifica que nenhum download ocorreu.
Então('nenhum download deve ser iniciado') do
  verify_no_file_download_occurred
end