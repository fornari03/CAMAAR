Dado('(que )existe um formulário {string}') do |titulo_form|
  docente = Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Docente Relatorio", email: "doc_rel@test.com", matricula: "DR01", 
    usuario: "doc_rel", password: "password", ocupacao: :docente, status: true
  )

  materia = Materia.find_or_create_by!(nome: "Engenharia de Software", codigo: "ES01")
  
  turma = Turma.find_or_create_by!(codigo: "TA", materia: materia) do |t|
    t.semestre = "2025.1"
    t.docente = docente
    t.horario = "24M12"
  end

  template = Template.find_or_create_by!(titulo: "Template Padrão") do |t|
    t.name = "Template Padrão"
    t.id_criador = docente.id
    t.participantes = "todos"
  end

  @formulario_relatorio = Formulario.create!(
    template: template,
    turma: turma,
    titulo_envio: titulo_form,
    data_criacao: Time.current,
    data_encerramento: 30.days.from_now
  )
end

Dado('o formulário {string} tem {string} respostas submetidas') do |titulo_form, qtd_str|
  form = Formulario.find_by(titulo_envio: titulo_form)
  qtd = qtd_str.to_i

  qtd.times do |i|
    aluno = Usuario.create!(
      nome: "Aluno Relatorio #{i}", 
      email: "aluno_rel_#{i}_#{Time.now.to_i}@test.com", 
      matricula: "2025#{i}#{Time.now.to_i}", 
      usuario: "aluno_rel_#{i}_#{Time.now.to_i}", 
      password: "password", 
      ocupacao: :discente, 
      status: true
    )
    
    Matricula.create!(usuario: aluno, turma: form.turma)
    
    Resposta.create!(
      formulario: form,
      participante: aluno,
      data_submissao: Time.current
    )
  end
end

Dado('que eu estou na página de resultados do formulário {string}') do |titulo_form|
  form = Formulario.find_by(titulo_envio: titulo_form)
  visit resultado_path(form)
end

Então('um download de um arquivo {string} deve ser iniciado') do |nome_arquivo|
  expect(page.response_headers['Content-Type']).to include('text/csv')
  expect(page.response_headers['Content-Disposition']).to include("attachment")
  expect(page.response_headers['Content-Disposition']).to include(nome_arquivo)
end

Então('nenhum download deve ser iniciado') do
  expect(page.response_headers['Content-Type']).to include('text/html')
  expect(page.response_headers['Content-Disposition']).to be_nil
end